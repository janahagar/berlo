# 🏛️ Berlin Landmarks Training Data

## **📁 Folder Structure**

This folder contains training data for Berlin landmark recognition. Each subfolder represents a different landmark:

### **🏛️ Major Landmarks**
- `brandenburg_gate/` - Brandenburg Gate (Brandenburger Tor)
- `museum_island/` - Museum Island (Museumsinsel)
- `berlin_cathedral/` - Berlin Cathedral (Berliner Dom)
- `east_side_gallery/` - East Side Gallery
- `checkpoint_charlie/` - Checkpoint Charlie
- `gendarmenmarkt/` - Gendarmenmarkt Square

### **🏰 Palaces & Royal Sites**
- `charlottenburg_palace/` - Charlottenburg Palace

### **🌳 Parks & Open Spaces**
- `tempelhofer_feld/` - Tempelhofer Feld (former airport)
- `tiergarten_park/` - Tiergarten Park
- `victory_column/` - Victory Column (Siegessäule)

### **🏙️ Modern Berlin**
- `potsdamer_platz/` - Potsdamer Platz
- `hackescher_markt/` - Hackescher Markt
- `prenzlauer_berg/` - Prenzlauer Berg neighborhood

### **🎪 Entertainment & Sports**
- `berlin_zoo/` - Berlin Zoo
- `olympic_stadium/` - Olympic Stadium

---

## **📸 Image Requirements**

### **Format & Quality**
- **Format**: JPEG (.jpg) or PNG (.png)
- **Size**: 224x224 pixels (recommended for ML training)
- **Quality**: High resolution, clear images
- **Quantity**: 50-200 images per landmark (more = better accuracy)

### **Image Variety**
For each landmark, include images with:
- ✅ **Different angles** (front, side, back, aerial)
- ✅ **Different lighting** (day, night, sunset, cloudy)
- ✅ **Different seasons** (spring, summer, autumn, winter)
- ✅ **Different weather** (sunny, rainy, snowy)
- ✅ **Different crowds** (empty, busy, events)
- ✅ **Different distances** (close-up, medium, far)

### **What to Avoid**
- ❌ Blurry or low-quality images
- ❌ Images with heavy filters or effects
- ❌ Images that don't clearly show the landmark
- ❌ Images with text overlays or watermarks
- ❌ Images that are too similar to each other

---

## **📋 Naming Convention**

Name your images descriptively:
```
brandenburg_gate/
├── front_day_01.jpg
├── front_night_01.jpg
├── side_sunset_01.jpg
├── aerial_summer_01.jpg
├── closeup_details_01.jpg
└── ...
```

---

## **🚀 Next Steps**

1. **Add Images**: Place 50-200 images in each folder
2. **Verify Quality**: Ensure images are clear and diverse
3. **Train Model**: Follow the training guide in `docs/firebase_ml_training_guide.md`
4. **Test Model**: Use the trained model in your Flutter app

---

## **📊 Expected Results**

With good training data, your model should achieve:
- **Accuracy**: 85-95% on Berlin landmarks
- **Speed**: Fast recognition (1-3 seconds)
- **Offline**: Works without internet connection
- **Custom**: Specifically trained for Berlin landmarks

**Happy training!** 🎯 