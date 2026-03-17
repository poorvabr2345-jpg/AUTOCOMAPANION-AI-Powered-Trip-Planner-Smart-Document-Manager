import os
from flask import Flask, request, jsonify
from flask_cors import CORS
import google.generativeai as genai

# =====================================================
# GEMINI CONFIGURATION (LOCALHOST ONLY)
# =====================================================

# 🔑 Put your Gemini API key here OR set as environment variable
genai.configure(api_key="AIzaSyA1NixTcNDC5DhCNs5hQl1WWplMLxRRpfw")


MODEL_NAME = "models/gemini-2.5-flash"

app = Flask(__name__)
CORS(app)

def get_destination_images(destination, num_images=3):
    """
    Generate destination images using Lorem Picsum
    Returns list of image URLs
    """
    try:
        # Using Lorem Picsum (no API key needed, always works)
        # Create unique seed from destination name
        seed = destination.replace(' ', '-').lower()
        images = []
        for i in range(num_images):
            # Generate unique URL for each image
            url = f"https://picsum.photos/800/600?random={seed}-{i}"
            images.append(url)
        print(f"Generated images: {images}")
        return images
    except Exception as e:
        print(f"Image generation error: {e}")
        # Fallback
        return [f"https://picsum.photos/800/600?random={i}" for i in range(num_images)]

def build_prompt(d):
    interests = ", ".join(d.get("interests", [])) or "general sightseeing"

    return f"""
You are an AI tour planner for a mobile application.

Generate a CLEAN, WELL-ORGANIZED road trip itinerary that is easy to display in a mobile UI.

STRICT FORMAT RULES (MUST FOLLOW):
- Do NOT use markdown symbols like **, ###, ---, *
- Do NOT use emojis
- Do NOT write long paragraphs
- Use clear headings and bullet points only
- Keep spacing consistent
- Separate each section with a blank line
- Always mention REALISTIC hotel and restaurant names based on the route
- ALL suggestions must fit within the given budget

FORMAT EXACTLY LIKE THIS:

Trip Overview:
- Route: {d.get("start_location")} to {d.get("destination")}
- Total days: {d.get("days")}
- Travelers: {d.get("travelers")}
- Budget: {d.get("budget")}

Fuel Summary:
- Estimated total distance: ___ km
- Vehicle mileage: ___ km per liter
- Total fuel required: ___ liters
- Estimated fuel cost: ___
- Fuel cost included in budget: Yes

Day 1:
Morning:
- Activity
- Breakfast place: Shop name, location, approx cost

Afternoon:
- Activity
- Lunch place: Restaurant name, location, approx cost

Evening:
- Activity

Night:
- Dinner place: Restaurant name, location, approx cost
- Stay: Hotel name, location, per-night cost

(Repeat same structure for all days)

Total Cost Breakdown:
- Stay total: ___
- Food total: ___
- Fuel total: ___
- Other expenses: ___
- Final estimated cost: ___
- Within budget: Yes

Safety Tips:
- Tip
- Tip
- Tip

Now generate the itinerary using this data:
Start location: {d.get("start_location")}
Destination: {d.get("destination")}
Days: {d.get("days")}
Travelers: {d.get("travelers")}
Budget: {d.get("budget")}
Interests: {interests}
""".strip()


@app.post("/api/ai-tour-plan")
def ai_tour_plan():
    data = request.get_json(force=True)

    try:
        # Generate itinerary
        model = genai.GenerativeModel(MODEL_NAME)
        response = model.generate_content(build_prompt(data))
        
        # Fetch destination images based on trip days
        destination = data.get("destination", "")
        trip_days = data.get("days", 3)
        print(f"🖼️ Fetching {trip_days} images for: {destination}")
        images = get_destination_images(destination, num_images=trip_days)
        print(f"✅ Generated {len(images)} images: {images}")

        return jsonify({
            "success": True,
            "itinerary": response.text,
            "destination_images": images,
            "destination": destination
        })
    except Exception as e:
        print(f"❌ Error: {e}")
        return jsonify({
            "success": False,
            "error": str(e)
        }), 500

@app.get("/ping")
def ping():
    return jsonify({"status": "ok"})

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5001)