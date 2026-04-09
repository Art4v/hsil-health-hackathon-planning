import cv2
import mediapipe as mp
import numpy as np

mp_drawing = mp.solutions.drawing_utils
mp_pose = mp.solutions.pose
mp_hands = mp.solutions.hands

POSE_LANDMARKS = {
    "LEFT_SHOULDER":  mp_pose.PoseLandmark.LEFT_SHOULDER,
    "RIGHT_SHOULDER": mp_pose.PoseLandmark.RIGHT_SHOULDER,
    "LEFT_ELBOW":     mp_pose.PoseLandmark.LEFT_ELBOW,
    "RIGHT_ELBOW":    mp_pose.PoseLandmark.RIGHT_ELBOW,
    "LEFT_WRIST":     mp_pose.PoseLandmark.LEFT_WRIST,
    "RIGHT_WRIST":    mp_pose.PoseLandmark.RIGHT_WRIST,
}

pose  = mp_pose.Pose(min_detection_confidence=0.5, min_tracking_confidence=0.5)
hands = mp_hands.Hands(min_detection_confidence=0.5, min_tracking_confidence=0.5)

cap = cv2.VideoCapture(2)

while cap.isOpened():
    ret, frame = cap.read()
    if not ret:
        break

    frame = cv2.flip(frame, 1)
    h, w = frame.shape[:2]
    rgb = cv2.cvtColor(frame, cv2.COLOR_BGR2RGB)

    pose_results  = pose.process(rgb)
    hands_results = hands.process(rgb)

    # --- Pose: shoulders, elbows, wrists ---
    if pose_results.pose_landmarks:
        lm = pose_results.pose_landmarks.landmark

        for name, idx in POSE_LANDMARKS.items():
            lx = int(lm[idx].x * w)
            ly = int(lm[idx].y * h)
            cv2.circle(frame, (lx, ly), 8, (0, 255, 128), -1)
            cv2.putText(frame, name, (lx + 10, ly),
                        cv2.FONT_HERSHEY_SIMPLEX, 0.4, (0, 255, 128), 1)

        # Draw connections: shoulder->elbow->wrist for each arm
        for side in ("LEFT", "RIGHT"):
            pts = []
            for joint in ("SHOULDER", "ELBOW", "WRIST"):
                idx = POSE_LANDMARKS[f"{side}_{joint}"]
                pts.append((int(lm[idx].x * w), int(lm[idx].y * h)))
            cv2.polylines(frame, [np.array(pts)], False, (0, 200, 100), 2)

    # --- Hands ---
    if hands_results.multi_hand_landmarks:
        for hand_lm, handedness in zip(
            hands_results.multi_hand_landmarks,
            hands_results.multi_handedness
        ):
            label = handedness.classification[0].label  # "Left" or "Right"
            color = (255, 128, 0) if label == "Right" else (0, 128, 255)

            mp_drawing.draw_landmarks(
                frame,
                hand_lm,
                mp_hands.HAND_CONNECTIONS,
                mp_drawing.DrawingSpec(color=color, thickness=2, circle_radius=3),
                mp_drawing.DrawingSpec(color=color, thickness=2),
            )

            # Label above wrist
            wrist = hand_lm.landmark[mp_hands.HandLandmark.WRIST]
            wx, wy = int(wrist.x * w), int(wrist.y * h)
            cv2.putText(frame, f"{label} Hand", (wx, wy - 12),
                        cv2.FONT_HERSHEY_SIMPLEX, 0.5, color, 2)

    cv2.imshow("Pose + Hands Tracking", frame)
    if cv2.waitKey(1) & 0xFF == ord("q"):
        break

cap.release()
pose.release()
hands.release()
cv2.destroyAllWindows()