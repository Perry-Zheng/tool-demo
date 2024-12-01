from flask import Flask
from scripts.routes import register_blueprints
from scripts.config import configure_app


def create_app():
    """应用工厂函数"""
    app = Flask(
        __name__,
        template_folder="../html",
        static_folder="../static",
        static_url_path="/static",
    )

    # 配置应用
    configure_app(app)

    # 注册蓝图
    register_blueprints(app)

    return app
