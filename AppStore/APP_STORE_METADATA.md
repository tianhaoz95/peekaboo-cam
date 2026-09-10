# App Store Connect Submission Metadata

## 1. App Information
* **App Name:** ToddlerCam: Dual Baby Camera
* **Subtitle:** Dual Camera & Watch Remote
* **Bundle ID:** `com.hejitech.kidscam`
* **SKU:** `HEJI-KIDSCAM-001`
* **Primary Language:** English (U.S.)
* **Primary Category:** Photo & Video
* **Secondary Category:** Kids
* **Kids Designation:** Made for Kids (Ages 5 and Under)
* **Price:** Free / Tier 0 (No in-app purchases, No ads)
* **Copyright:** © 2026 HejiTech LLC

---

## 2. Version Information (v1.0.0)

### Promotional Text (170 characters max)
> Capture both your toddler and your reaction at once! Includes Apple Watch parent remote, child-safe screen lock, and Guided Access protection.

### Subtitle (30 characters max)
> Dual Camera & Watch Remote

### Keywords (100 characters max, comma-separated)
```
toddler camera,baby camera,kids camera,dual camera,watch remote,guided access,child safe,baby photos
```
*(Exact length: 99 characters)*

### Description
```
ToddlerCam is the ultimate child-friendly camera designed especially for babies, toddlers, and playful parents! 

Turn photography into a joyful interactive adventure with simultaneous front-and-rear dual camera capture, tactile toddler controls, and a companion Apple Watch remote that lets parents capture the magic without taking the phone away from little hands.

✨ KEY FEATURES:

📸 DUAL CAMERA CAPTURE (Front + Rear Together)
• See what your toddler is looking at AND their priceless smile simultaneously!
• 100% Edge-to-edge Picture-in-Picture (PiP) fullscreen dual preview.
• Tap floating PiP card or watch remote to seamlessly swap primary and selfie angles.
• Automatically saves both original high-resolution photos and a composite reaction keepsake to your Photos library.

⌚️ APPLE WATCH PARENT REMOTE
• Keep your phone safely in your child's hands while controlling the camera from your wrist!
• Big, tactile wrist shutter button with haptic feedback.
• Silly Attention Grabber soundboard: Tap puppy bark, duck quack, kitty meow, or baby giggle on your watch to make the phone play funny sounds and capture your toddler looking and smiling right at the lens!
• Remotely lock screen touches, swap camera angles, and review the last photo thumbnail right on your wrist.

🛡️ GUIDED ACCESS EDUCATION & SAFETY
• Step-by-step interactive parent tutorial to enable Apple Guided Access.
• Guided Access locks the phone to ToddlerCam with a triple-click of the side button, disabling home swipe gestures, notification center, and hardware volume buttons so your toddler stays 100% inside the app.
• Live indicator alerts parents whether Guided Access is currently active.

🔒 TODDLER-SAFE SCREEN LOCK & BUBBLE CANVAS
• Turn on Toddler Lock to turn the screen into a magical touch canvas!
• Little fingers tapping the screen generate colorful popping bubbles, stars, and musical chirps without interrupting the live camera stream.
• Child-proof Parental Gate (math challenge) ensures only grown-ups can access settings or camera roll.

✨ REAL-TIME APPLE VISION FACE MASKS (Controlled via Apple Watch)
• Fun, interactive face masks (Crown, Lion, Sunglasses, Kitty, Puppy, Unicorn, Panda, Bunny, Star Eyes)!
• Powered by native Apple Vision framework: masks dynamically track head movement and tilt with your child's head roll in real time!
• Settings are exclusively on the parent's Apple Watch so the toddler's iPhone screen stays 100% clean, locked, and distraction-free.

⌚️ APPLE WATCH COMPLICATIONS & REMOTE LAUNCHER
• Add ToddlerCam complications to your favorite Apple Watch face for instant one-tap camera shutter or silly animal sounds.
• Switch complications directly from the Watch Complications studio in Parent Hub.

👶 100% PRIVATE & SAFE FOR KIDS
• Built specifically for the App Store Kids Category (Ages 5 and Under).
• ZERO data collection, ZERO tracking SDKs, and ZERO advertisements.
• All camera feeds and Apple Vision face tracking are processed strictly on-device.
```

---

## 3. URLs
* **Support URL:** `https://hejitech.com/support/kidscam`
* **Marketing URL:** `https://hejitech.com/toddlercam`
* **Privacy Policy URL:** `https://hejitech.com/privacy/kidscam`

---

## 4. App Privacy Nutrition Labels
In App Store Connect under **App Privacy**:
* **Data Collection:** Select **"Data Not Collected"**
* *Confirmation:* The app does not collect or track any user data, biometric information, location, analytics, or diagnostics. All processing is on-device.

---

## 5. Age Rating & Content Questionnaire
Answer **NO / NONE** to all content questionnaires:
* Cartoon or Fantasy Violence: **None**
* Realistic Violence: **None**
* Sexual Content or Nudity: **None**
* Alcohol, Tobacco, or Drug Use: **None**
* Gambling or Contests: **None**
* Horror / Fear Themes: **None**
* Medical / Treatment Information: **None**
* Profanity or Crude Humor: **None**
* Unrestricted Web Access: **No**
* Made for Kids: **Yes (Ages 5 and Under)**

**Resulting Rating:** 4+ (Made for Kids)

---

## 6. App Review Notes (for Apple Review Team)
```
Dear Apple App Review Team,

Thank you for reviewing ToddlerCam! Here are helpful notes to test all features:

1. DUAL CAMERA HARDWARE & SIMULATION:
- On physical devices (iPhone XS and newer running iOS 17+), ToddlerCam utilizes AVCaptureMultiCamSession to stream both front and back cameras simultaneously.
- When running in the simulator or non-multicam hardware, ToddlerCam automatically provides a simulated interactive dual feed (interactive toddler selfie character on front + toy room on back) so all capture, stickers, layout modes, and UI workflows can be fully tested.

2. APPLE WATCH COMPANION APP:
- Install the companion watchOS target (KidsCamWatch) on a paired Apple Watch.
- Ensure Bluetooth/Wi-Fi is active. The watch will indicate "Connected".
- Tapping the large Shutter button on the watch triggers photo capture on the iPhone.
- Tapping any animal icon (Quack, Woof, etc.) on the watch plays the sound on the iPhone speaker.
- Last photo thumbnail is sent back to the watch for instant wrist review.

3. GUIDED ACCESS TUTORIAL:
- Tap the "Guided Access Setup" button on the top-left of the camera screen or in Parent Settings.
- This view checks UIAccessibility.isGuidedAccessEnabled and provides an illustrated 4-step tutorial and direct link to Settings.

4. PARENTAL GATE:
- Accessing Parent Settings or Gallery requires answering a simple addition problem to keep toddlers from leaving the camera screen.

5. CHILD PRIVACY:
- ToddlerCam collects zero data and complies strictly with Guideline 1.3 & 5.1.4 (Kids Category & COPPA).

Contact Email: review-contact@hejitech.com
```

---

## 7. Screenshot Mockup Copy & Suggested Slides

### Slide 1 (Hero Dual Camera)
* **Headline:** Dual Camera Fun for Little Hands
* **Subhead:** Capture both your baby's smile and their world at once!
* **Visual:** Picture-in-Picture layout showing toddler selfie + toy room.

### Slide 2 (Watch Remote Control)
* **Headline:** Parent Apple Watch Remote
* **Subhead:** Snap photos & play silly animal sounds right from your wrist!
* **Visual:** Apple Watch screen showing big shutter button & Quack/Woof soundboard.

### Slide 3 (Guided Access & Toddler Lock)
* **Headline:** 100% Toddler Safe
* **Subhead:** Guided Access & bubble screen lock keep kids safely inside the app.
* **Visual:** Bubble popping canvas with Guided Access active badge.

### Slide 4 (Apple Watch Face Masks Remote)
* **Headline:** Remote Face Tracking Masks
* **Subhead:** Choose fun animal masks from your watch that track your toddler's smile!
* **Visual:** Apple Watch Face Masks selector with toddler wearing lion mask on iPhone screen.

### Slide 5 (Watch Complications & Easy Shutter)
* **Headline:** Watch Complications & Instant Shutter
* **Subhead:** Add shortcuts to your watch face for instant captures and giggle sounds.
* **Visual:** Apple Watch complications on modular face and quick shutter view.
