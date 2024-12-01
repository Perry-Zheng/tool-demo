from flask import Blueprint, jsonify, request
from scripts.utils.validators import validate_params

api_bp = Blueprint("api", __name__)


@api_bp.route("/submit", methods=["POST"])
def submit():
    """API提交接口"""
    param1 = request.form.get("param1")
    param2 = request.form.get("param2")

    # 参数验证
    validation_result = validate_params(param1, param2)
    if validation_result.get("error"):
        return jsonify(validation_result), 400

    response = {"param1": param1, "param2": param2 if param2 else "Not provided"}
    return jsonify(response)
