print("🚀 STARTING FLASK VIA EXTERNAL RUNNER")

from ai_tour_backend import app

app.run(
    host="0.0.0.0",
    port=5001,  # Match the port in Flutter app
    debug=False,
    use_reloader=False
)
