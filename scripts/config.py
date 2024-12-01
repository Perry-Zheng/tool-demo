from settings.languages import LANGUAGES, DEFAULT_LANGUAGE
from flask import session
from settings.config import SERVICE_CONFIG


def configure_app(app):
    """配置 Flask 应用"""
    # 基础配置
    app.secret_key = "your-secret-key-here"

    # 注册语言中间件
    @app.before_request
    def before_request():
        if "language" not in session:
            session["language"] = DEFAULT_LANGUAGE
