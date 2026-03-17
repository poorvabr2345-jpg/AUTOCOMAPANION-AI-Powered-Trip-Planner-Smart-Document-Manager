import re
import cv2
import numpy as np
import pytesseract
from flask import Flask, request, jsonify
from flask_cors import CORS
from datetime import datetime
from dateutil import parser

# ================== CONFIG ==================
app = Flask(__name__)
CORS(app)

pytesseract.pytesseract.tesseract_cmd = r"C:\Program Files\Tesseract-OCR\tesseract.exe"

# ================== IMAGE PREPROCESS ==================
def preprocess(image):
    # 🔹 ADDED: stronger preprocessing for dense insurance layouts
    image = cv2.resize(image, None, fx=2.5, fy=2.5, interpolation=cv2.INTER_CUBIC)
    gray = cv2.cvtColor(image, cv2.COLOR_BGR2GRAY)
    gray = cv2.bilateralFilter(gray, 9, 75, 75)

    thresh = cv2.adaptiveThreshold(
        gray,
        255,
        cv2.ADAPTIVE_THRESH_GAUSSIAN_C,
        cv2.THRESH_BINARY,
        31,
        11,
    )
    return thresh

# ================== TEXT NORMALIZATION ==================
def normalize(text: str) -> str:
    text = text.replace("\n", " ")
    text = re.sub(r"\s+", " ", text)
    text = text.lower()

    fixes = {
        "0f": "of",
        "va1id": "valid",
        "ti1l": "till",
        "unti1": "until",
        "1icence": "licence",
    }
    for k, v in fixes.items():
        text = text.replace(k, v)

    return text.strip()

# ================== DATE VALIDATION ==================
def valid_date(d: datetime) -> bool:
    now = datetime.now()
    return 1990 <= d.year <= now.year + 15

# ================== EXPIRY DATE EXTRACTION ==================
def extract_expiry(text: str) -> str:
    text = normalize(text)

    text = re.sub(r"\([a-z]+\)", "", text, flags=re.IGNORECASE)
    text = re.sub(r"\b\d{1,2}:\d{2}.*?(?=\b|$)", "", text)

    context_patterns = [
        r"(expiry date|valid till|valid upto|valid until|expires on)\s*[:\-]?\s*([0-9\/\-a-z ]+)",
        r"policy period.*?to\s*([0-9\/\-a-z ]+)",
        r"from\s+[0-9\/\-a-z ]+\s+to\s+([0-9\/\-a-z ]+)",
        r"(reg\/fc|fc|registration)\s*(valid)?\s*(upto|until|till)\s*[:\-]?\s*([0-9\/\-a-z ]+)",
        r"valid\s*till\s*[:\-]?\s*([0-9\/\-a-z ]+)",
        r"valid\s*upto\s*[:\-]?\s*([0-9\/\-a-z ]+)",
        r"midnight\s+of\s*([0-9\/\-a-z ]+)",
    ]

    dates = []

    for pat in context_patterns:
        matches = re.findall(pat, text, flags=re.IGNORECASE)
        for m in matches:
            candidate = m[-1]
            try:
                d = parser.parse(candidate, fuzzy=True, dayfirst=True)
                if valid_date(d):
                    dates.append(d)
            except:
                pass

    if dates:
        return max(dates).strftime("%d-%m-%Y")

    fallback_patterns = [
        r"\b\d{1,2}[\/\-]\d{1,2}[\/\-]\d{4}\b",
        r"\b\d{1,2}\s+(jan|feb|mar|apr|may|jun|jul|aug|sep|oct|nov|dec)[a-z]*\s+\d{4}\b",
        r"\b\d{1,2}(st|nd|rd|th)?\s+of\s+[a-z]+\s+\d{4}\b",
    ]

    for pat in fallback_patterns:
        for m in re.findall(pat, text, flags=re.IGNORECASE):
            try:
                d = parser.parse(m, fuzzy=True, dayfirst=True)
                if valid_date(d):
                    dates.append(d)
            except:
                pass

    if dates:
        return max(dates).strftime("%d-%m-%Y")
        # 🔹 INSURANCE TABLE-SPECIFIC FIX (VERY IMPORTANT)
    policy_table_patterns = [
        r"to\s*(\d{1,2}\s*[-/]\s*[a-z]{3}\s*[-/]\s*\d{4})",
        r"to\s*(\d{1,2}[-/]\d{1,2}[-/]\d{4})",
        r"to\s*(\d{1,2}\s+[a-z]+\s+\d{4})",
    ]

    for pat in policy_table_patterns:
        matches = re.findall(pat, text, flags=re.IGNORECASE)
        for m in matches:
            try:
                d = parser.parse(m, fuzzy=True, dayfirst=True)
                if valid_date(d):
                    dates.append(d)
            except:
                pass

    if dates:
        return max(dates).strftime("%d-%m-%Y")


    return "Not detected"

# ================== DOCUMENT NUMBER EXTRACTION ==================
def extract_document_number(text: str, doc_type: str) -> str:
    text = normalize(text)

    BLOCK_WORDS = {
        "schedule", "certificate", "insurance",
        "policy", "motor", "vehicle", "cover"
    }

    patterns = []

    # INSURANCE
    if doc_type == "insurance":
        patterns = [
            # 🔹 ADDED: THIS handles your shared policy format
            r"policy\s*no\.?\s*[:\-]?\s*([a-z0-9\/\-]{10,40})",

            r"(policy|certificate|schedule|proposal|reference|transaction|invoice)\s*(no|number)?\s*[:\-]?\s*([a-z0-9\/\-]{8,40})",
            r"\b[a-z]{2,5}\d{8,20}\b",
            r"\b\d{12,30}\b",
        ]

    elif doc_type == "rc":
        patterns = [
            r"(registration|regn|reg|vehicle)\s*(no|number)?\s*[:\-]?\s*([a-z]{2}\d{2}[a-z]{2}\d{4})",
            r"\b[a-z]{2}\d{2}[a-z]{2}\d{4}\b",
        ]

    elif doc_type == "licence":
        patterns = [
            r"(dl|driving licence|driving license|licence|license)\s*(no|number)?\s*[:\-]?\s*([a-z]{2}\d{2}\s*\d{8,12})",
            r"\b[a-z]{2}\d{2}\s*\d{8,12}\b",
        ]

    elif doc_type == "puc":
        patterns = [
            r"(puc|pollution)\s*(no|number)?\s*[:\-]?\s*([a-z0-9\-]{6,20})",
        ]

    for pat in patterns:
        m = re.search(pat, text, flags=re.IGNORECASE)
        if m:
            val = m.group(len(m.groups())).replace(" ", "").upper()
            if val.lower() not in BLOCK_WORDS:
                return val

    return "Not detected"

# ================== ROUTE ==================
@app.post("/api/document/scan")
def scan_document():
    if "file" not in request.files:
        return jsonify({"success": False, "error": "No file uploaded"}), 400

    doc_type = request.form.get("doc_type", "insurance").lower()
    file = request.files["file"]

    image_bytes = np.frombuffer(file.read(), np.uint8)
    image = cv2.imdecode(image_bytes, cv2.IMREAD_COLOR)

    if image is None:
        return jsonify({"success": False, "error": "Invalid image"}), 400

    # 🔹 MODIFIED: layout-aware OCR for insurance docs
    config = "--oem 3 --psm 11 -l eng -c preserve_interword_spaces=1"

    text1 = pytesseract.image_to_string(image, config=config)
    text2 = pytesseract.image_to_string(preprocess(image), config=config)
    text3 = pytesseract.image_to_string(preprocess(image), config="--oem 3 --psm 12 -l eng")

    full_text = text1 + " " + text2 + " " + text3

    expiry = extract_expiry(full_text)
    doc_no = extract_document_number(full_text, doc_type)

    return jsonify({
        "success": True,
        "document_type": doc_type,
        "document_number": doc_no,
        "expiry_date": expiry,
        "confidence": 0.97
    })

# ================== RUN ==================
if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5002)