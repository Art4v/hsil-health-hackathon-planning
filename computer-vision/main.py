import cv2 # openCV for webcam capture and image display
import mediapipe as mp # media pipe for hand tracking

mp_hands = mp.solutions.hands # get hand solution module 
mp_draw = mp.solutions.drawing_utils # get drawing utilities to render landmarks on frames

cap = cv2.VideoCapture(0) # open the default webcam as a vid capture source

# initialise the hands model with detection and tracking confidence thresholds
with mp_hands.Hands(min_detection_confidence = 0.7, min_tracking_confidence = 0.5) as hands:
    # while camera is opened
    while cap.isOpened():
        # read a single frame, ret is return, frame is the actual image
        ret, frame = cap.read()
        if not ret:
            break

        rgb = cv2.cvtColor(frame, cv2.COLOR_BGR2RGB) # convert from bgr to rgb (mediapipe expects rgb)
        results = hands.process(rgb) # run the mediapipe tool to process landmarks

        # if landmarks found
        if results.multi_hand_landmarks:
            for hand_landmarks in results.multi_hand_landmarks:
                # draw the landmarks onto the actual frame and connect landmarks
                mp_draw.draw_landmarks(frame, hand_landmarks, mp_hands.HAND_CONNECTIONS)

        # show frame with hand connections
        cv2.imshow("Hands", frame)

        if cv2.waitKey(1) & 0xFF == ord('q'):  # wait 1ms for a key press; if 'q' is pressed, exit
            break  

cap.release()  # release the webcam resource so other programs can use it
