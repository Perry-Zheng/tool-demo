#!/usr/bin/env python3
from scripts.app import create_app
from settings.config import SERVICE_CONFIG

if __name__ == "__main__":
    app = create_app()
    app.run(
        debug=SERVICE_CONFIG["DEBUG"],
        host=SERVICE_CONFIG["HOST"],
        port=SERVICE_CONFIG["PORT"],
    )
