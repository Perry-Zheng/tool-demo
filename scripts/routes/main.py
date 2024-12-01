from flask import Blueprint, render_template, session, redirect, url_for, request
from settings.languages import LANGUAGES, DEFAULT_LANGUAGE

main_bp = Blueprint("main", __name__)


@main_bp.route("/")
def index():
    """首页路由"""
    lang = session.get("language", DEFAULT_LANGUAGE)
    return render_template(
        "index.html", lang=LANGUAGES[lang], current_lang=lang, languages=LANGUAGES
    )


@main_bp.route("/submit", methods=["GET", "POST"])
def submit():
    """提交页面路由"""
    lang = session.get("language", DEFAULT_LANGUAGE)
    if request.method == "POST":
        return handle_submit(lang)
    return render_template(
        "submit.html", lang=LANGUAGES[lang], current_lang=lang, languages=LANGUAGES
    )


@main_bp.route("/switch_language/<lang>")
def switch_language(lang):
    """语言切换路由"""
    if lang in LANGUAGES:
        session["language"] = lang
    return redirect(request.referrer or url_for("main.index"))


def handle_submit(lang):
    """处理表单提交"""
    param1 = request.form.get("param1")
    param2 = request.form.get("param2")

    if not param1:
        return render_template(
            "submit.html",
            lang=LANGUAGES[lang],
            current_lang=lang,
            languages=LANGUAGES,
            result={"error": "param1 is required"},
            error=True,
        )

    result = {"param1": param1, "param2": param2 if param2 else "Not provided"}

    return render_template(
        "submit.html",
        lang=LANGUAGES[lang],
        current_lang=lang,
        languages=LANGUAGES,
        result=result,
    )
