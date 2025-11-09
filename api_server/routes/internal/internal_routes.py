from aiohttp import web
from typing import Optional
from folder_paths import folder_names_and_paths, get_directory_by_type
from api_server.services.terminal_service import TerminalService
import app.logger
import os
import nodes
import asyncio
import logging

class InternalRoutes:
    '''
    The top level web router for internal routes: /internal/*
    The endpoints here should NOT be depended upon. It is for ComfyUI frontend use only.
    Check README.md for more information.
    '''

    def __init__(self, prompt_server):
        self.routes: web.RouteTableDef = web.RouteTableDef()
        self._app: Optional[web.Application] = None
        self.prompt_server = prompt_server
        self.terminal_service = TerminalService(prompt_server)

    def setup_routes(self):
        @self.routes.get('/logs')
        async def get_logs(request):
            return web.json_response("".join([(l["t"] + " - " + l["m"]) for l in app.logger.get_logs()]))

        @self.routes.get('/logs/raw')
        async def get_raw_logs(request):
            self.terminal_service.update_size()
            return web.json_response({
                "entries": list(app.logger.get_logs()),
                "size": {"cols": self.terminal_service.cols, "rows": self.terminal_service.rows}
            })

        @self.routes.patch('/logs/subscribe')
        async def subscribe_logs(request):
            json_data = await request.json()
            client_id = json_data["clientId"]
            enabled = json_data["enabled"]
            if enabled:
                self.terminal_service.subscribe(client_id)
            else:
                self.terminal_service.unsubscribe(client_id)

            return web.Response(status=200)


        @self.routes.get('/folder_paths')
        async def get_folder_paths(request):
            response = {}
            for key in folder_names_and_paths:
                response[key] = folder_names_and_paths[key][0]
            return web.json_response(response)

        @self.routes.get('/files/{directory_type}')
        async def get_files(request: web.Request) -> web.Response:
            directory_type = request.match_info['directory_type']
            if directory_type not in ("output", "input", "temp"):
                return web.json_response({"error": "Invalid directory type"}, status=400)

            directory = get_directory_by_type(directory_type)
            sorted_files = sorted(
                (entry for entry in os.scandir(directory) if entry.is_file()),
                key=lambda entry: -entry.stat().st_mtime
            )
            return web.json_response([entry.name for entry in sorted_files], status=200)

        @self.routes.post('/restart')
        async def restart(request):
            """重新加载所有自定义节点和扩展节点"""
            try:
                logging.info("正在重新加载节点...")
                # 重新加载所有节点（自定义节点和内置扩展节点）
                import_failed = await nodes.init_extra_nodes(init_custom_nodes=True, init_api_nodes=True)
                
                if import_failed:
                    logging.warning(f"部分节点加载失败: {import_failed}")
                    return web.json_response({
                        "success": True, 
                        "message": "重启完成，但部分节点加载失败",
                        "failed_nodes": import_failed
                    })
                else:
                    logging.info("节点重新加载完成")
                    return web.json_response({
                        "success": True, 
                        "message": "所有节点重新加载完成"
                    })
            except Exception as e:
                logging.error(f"重启过程中出错: {e}")
                return web.json_response({
                    "success": False, 
                    "error": str(e)
                }, status=500)

    def get_app(self):
        if self._app is None:
            self._app = web.Application()
            self.setup_routes()
            self._app.add_routes(self.routes)
        return self._app
