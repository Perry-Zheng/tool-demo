def validate_params(param1, param2=None):
    """验证参数"""
    if not param1:
        return {"error": "param1 is required"}
    return {}
