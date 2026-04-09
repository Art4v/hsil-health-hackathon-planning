# Library imports
import cv2
import mediapipe as mp
import numpy as np

# Get utilities from libraries
mp_drawing = mp.solutions.drawing_utils
mp_pose = mp.solutions.pose
mp_hands = mp.solutions.hands

# -----------------------------------------------------------------------------
# MAPPING NAMES TO MEDIAPOSE LANDMARS
# -----------------------------------------------------------------------------

# We only care about the 6 upper-body joints relevant to the robotic arm
POSE_LANDMARKS = {
    "LEFT_SHOULDER":  mp_pose.PoseLandmark.LEFT_SHOULDER,
    "RIGHT_SHOULDER": mp_pose.PoseLandmark.RIGHT_SHOULDER,
    "LEFT_ELBOW":     mp_pose.PoseLandmark.LEFT_ELBOW,
    "RIGHT_ELBOW":    mp_pose.PoseLandmark.RIGHT_ELBOW,
    "LEFT_WRIST":     mp_pose.PoseLandmark.LEFT_WRIST,
    "RIGHT_WRIST":    mp_pose.PoseLandmark.RIGHT_WRIST,
}

# Fingertip landmark indices (one per finger, excluding thumb)
FINGER_TIPS = [
    mp_hands.HandLandmark.INDEX_FINGER_TIP,
    mp_hands.HandLandmark.MIDDLE_FINGER_TIP,
    mp_hands.HandLandmark.RING_FINGER_TIP,
    mp_hands.HandLandmark.PINKY_TIP,
]

# PIP = proximal interphalangeal joint = middle knuckle
# Used as the reference point: tip further from wrist than PIP => finger extended
FINGER_PIPS = [
    mp_hands.HandLandmark.INDEX_FINGER_PIP,
    mp_hands.HandLandmark.MIDDLE_FINGER_PIP,
    mp_hands.HandLandmark.RING_FINGER_PIP,
    mp_hands.HandLandmark.PINKY_PIP,
]

# Thumb moves laterally so we compare TIP vs IP (not PIP) to avoid false readings
THUMB_TIP = mp_hands.HandLandmark.THUMB_TIP
THUMB_IP  = mp_hands.HandLandmark.THUMB_IP

# -----------------------------------------------------------------------------
# FUNCTIONS TO KEEP TRACK OF HAND STATE
# -----------------------------------------------------------------------------

def is_finger_extended(lm, tip_idx, pip_idx, wrist_idx=mp_hands.HandLandmark.WRIST):
    """
    Compares Euclidean distance from wrist to tip vs wrist to PIP.
    If the tip is further away, the finger is considered extended.
    Works in normalised image space (x, y) — z is ignored here.
    """
    wrist = np.array([lm[wrist_idx].x, lm[wrist_idx].y])
    tip   = np.array([lm[tip_idx].x,   lm[tip_idx].y])
    pip   = np.array([lm[pip_idx].x,   lm[pip_idx].y])
    return np.linalg.norm(tip - wrist) > np.linalg.norm(pip - wrist)

def is_thumb_extended(lm):
    """Same logic as is_finger_extended but using the thumb's IP joint."""
    return is_finger_extended(lm, THUMB_TIP, THUMB_IP)

def get_hand_state(hand_lm):
    """
    Checks each finger and returns:
      state         - "Open" (4-5 up), "Closed" (0-1 up), or "Partial"
      fingers_up    - list of 5 bools [thumb, index, middle, ring, pinky]
      extended_count - how many fingers are currently extended
    """
    lm = hand_lm.landmark

    # Check thumb separately, then the four fingers in order
    fingers_up = [is_thumb_extended(lm)] + [
        is_finger_extended(lm, tip, pip)
        for tip, pip in zip(FINGER_TIPS, FINGER_PIPS)
    ]

    extended_count = sum(fingers_up)

    # Thresholds are intentionally loose to handle borderline cases
    if extended_count >= 4:
        state = "Open"
    elif extended_count <= 1:
        state = "Closed"
    else:
        state = "Partial"

    return state, fingers_up, extended_count

# -----------------------------------------------------------------------------
# INITIALISATION OF MODELS AND WEBCAM
# -----------------------------------------------------------------------------

# Initialise pose model — tracks full body, we'll just read the 6 joints we need
pose = mp_pose.Pose(min_detection_confidence=0.5, min_tracking_confidence=0.5)

# Initialise hands model — detects up to 2 hands by default
hands = mp_hands.Hands(min_detection_confidence=0.5, min_tracking_confidence=0.5)

cap = cv2.VideoCapture(2)

# -----------------------------------------------------------------------------
# RUN MODELS WHILE WEBCAM IS RUNNING
# -----------------------------------------------------------------------------
while cap.isOpened():
    ret, frame = cap.read()
    if not ret:
        break

    # Flip so the view mirrors the user (more intuitive for self-monitoring)
    frame = cv2.flip(frame, 1)
    h, w = frame.shape[:2]

    # MediaPipe expects RGB; OpenCV captures in BGR by default
    rgb = cv2.cvtColor(frame, cv2.COLOR_BGR2RGB)

    # Run both models on the same frame
    pose_results  = pose.process(rgb)
    hands_results = hands.process(rgb)

    # -----------------------------------------------------------------------------
    # POSE RENDERING
    # -----------------------------------------------------------------------------
    if pose_results.pose_landmarks:
        # Get list of landmarks, each with xyz values
        lm = pose_results.pose_landmarks.landmark

        # Draw a labelled dot at each of the 6 tracked joints
        for name, idx in POSE_LANDMARKS.items():
            lx = int(lm[idx].x * w)  # landmarks are normalised 0-1, scale to pixels
            ly = int(lm[idx].y * h)
            cv2.circle(frame, (lx, ly), 8, (0, 255, 128), -1)
            cv2.putText(frame, name, (lx + 10, ly),
                        cv2.FONT_HERSHEY_SIMPLEX, 0.4, (0, 255, 128), 1)

        # Connect shoulder -> elbow -> wrist as a polyline for each arm
        for side in ("LEFT", "RIGHT"):
            pts = []
            for joint in ("SHOULDER", "ELBOW", "WRIST"):
                idx = POSE_LANDMARKS[f"{side}_{joint}"]
                pts.append((int(lm[idx].x * w), int(lm[idx].y * h)))
            cv2.polylines(frame, [np.array(pts)], False, (0, 200, 100), 2)

    # -----------------------------------------------------------------------------
    # HAND RENDERING
    # -----------------------------------------------------------------------------
    if hands_results.multi_hand_landmarks:
        # Zip landmarks with handedness so we know which hand is which
        for hand_lm, handedness in zip(hands_results.multi_hand_landmarks, hands_results.multi_handedness):
            label = handedness.classification[0].label  # "Left" or "Right"
            state, fingers_up, count = get_hand_state(hand_lm)

            # Colour the entire hand skeleton based on open/partial/closed state
            if state == "Open":
                color = (0, 255, 0)    # green
            elif state == "Closed":
                color = (0, 0, 255)    # red
            else:
                color = (0, 165, 255)  # orange

            # Draw the 21-landmark hand skeleton using MediaPipe's built-in utility
            mp_drawing.draw_landmarks(
                frame,
                hand_lm,
                mp_hands.HAND_CONNECTIONS,
                mp_drawing.DrawingSpec(color=color, thickness=2, circle_radius=3),
                mp_drawing.DrawingSpec(color=color, thickness=2),
            )

            # Anchor the label to the wrist landmark position
            wrist = hand_lm.landmark[mp_hands.HandLandmark.WRIST]
            wx, wy = int(wrist.x * w), int(wrist.y * h)

            # Show hand side, state, and how many fingers are up
            cv2.putText(frame, f"{label}: {state} ({count}/5)",
                        (wx, wy - 12), cv2.FONT_HERSHEY_SIMPLEX, 0.6, color, 2)

            # Per-finger breakdown: letter = extended, underscore = curled
            # Order: Thumb, Index, Middle, Ring, Pinky
            finger_names = ["T", "I", "M", "R", "P"]
            breakdown = " ".join(
                name if up else "_"
                for name, up in zip(finger_names, fingers_up)
            )
            cv2.putText(frame, breakdown, (wx, wy + 20),
                        cv2.FONT_HERSHEY_SIMPLEX, 0.5, color, 1)
    
    cv2.imshow("Pose + Hands Tracking", frame)

    # q to quit
    if cv2.waitKey(1) & 0xFF == ord("q"):
        break

# Release all resources cleanly
cap.release()
pose.release()
hands.release()
cv2.destroyAllWindows()