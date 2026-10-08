# PDF Buddy

A Flutter web app for merging and splitting PDF files in the browser.

Live: https://pdf-buddy.pages.dev/

## 🚀 Features

### Core PDF Operations
- **PDF Merging**: Combine multiple PDF files into one document with drag-and-drop reordering
- **PDF Splitting**: Extract specific pages or page ranges from PDF documents
- **PDF Preview**: View PDF content with zoom and navigation controls
- **Drag & Drop Interface**: Intuitive file upload with visual feedback

### User Experience
- **Responsive Design**: Works seamlessly on desktop and mobile devices
- **Dark Theme**: Modern, eye-friendly interface
- **Progress Indicators**: Real-time feedback during PDF operations
- **Error Handling**: Clear error messages and recovery options
- **File Management**: Easy addition and removal of PDF files

### Technical Features
- **Client-Side Processing**: All operations happen locally in the browser
- **No Data Upload**: Files never leave your device, ensuring privacy
- **PWA Support**: Installable as a desktop/mobile app
- **Cross-Browser Compatibility**: Works on Chrome, Firefox, Edge, and Safari

## 🛠️ Technical Stack

- **Framework**: Flutter Web
- **State Management**: Riverpod
- **PDF Processing**: Syncfusion Flutter PDF
- **UI Components**: Material Design 3
- **File Handling**: Universal HTML
- **Fonts**: Google Fonts
- **Icons**: Font Awesome Flutter

## 📋 Prerequisites

- Flutter SDK (3.7.2 or higher)
- Dart SDK
- Web browser (Chrome, Firefox, Edge, or Safari)
- Git

## 🔧 Installation & Setup

1. **Clone the repository**
   ```bash
   git clone https://github.com/MantakaMahir/pdf_buddy.git
   cd pdf_buddy
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the application**
   ```bash
   flutter run -d chrome
   ```

4. **Build for production**
   ```bash
   flutter build web --release
   ```

## 🏗️ Project Structure

```
lib/
├── components/          # Reusable UI components
│   ├── pdf_drop_zone.dart
│   └── pdf_tools_panel.dart
├── features/           # Feature-specific implementations
│   ├── landing_page.dart
│   ├── merge_pdf_page.dart
│   ├── split_pdf_page.dart
│   └── pdf_viewer.dart
├── providers/          # State management providers
│   └── processing_providers.dart
├── services/           # Business logic and services
│   └── pdf_service.dart
└── utils/             # Utility functions and themes
    └── theme.dart
```

## 🎯 How to Use

### Merging PDFs
1. Navigate to the "Merge PDFs" section
2. Drag and drop or click to upload multiple PDF files
3. Reorder files by dragging them in the list
4. Click "Merge PDFs" to combine them
5. Download the merged PDF file

### Splitting PDFs
1. Navigate to the "Split PDF" section
2. Upload a PDF file
3. Define page ranges (e.g., "1-5", "10-15")
4. Click "Split PDF" to extract the specified pages
5. Download the new PDF with selected pages

## 🔒 Privacy & Security

- **100% Client-Side**: All PDF processing happens in your browser
- **No Server Communication**: Files are never uploaded to any server
- **Local Storage Only**: Temporary data is stored locally and cleared after use
- **No Tracking**: No analytics or user tracking implemented

## ⚡ Performance

- **Optimized Processing**: Efficient PDF manipulation with progress tracking
- **Memory Management**: Proper cleanup of resources after operations
- **Responsive UI**: Non-blocking operations with real-time progress updates
- **File Size Handling**: Optimized for various PDF sizes

## 🌐 Browser Support

| Browser | Version | Status |
|---------|---------|--------|
| Chrome  | 90+     | ✅ Fully Supported |
| Firefox | 88+     | ✅ Fully Supported |
| Edge    | 90+     | ✅ Fully Supported |
| Safari  | 14+     | ✅ Fully Supported |

## 🚧 Future Enhancements

- [ ] PDF compression and optimization
- [ ] Page rotation and manipulation
- [ ] PDF form filling
- [ ] Digital signatures
- [ ] Batch processing
- [ ] Custom themes
- [ ] Cloud storage integration

## 🧪 Testing

Run tests with:
```bash
flutter test
```

## Deployment

The GitHub Actions workflow deploys the release build to Cloudflare Pages on pushes to `main`. Configure the repository secrets `CLOUDFLARE_API_TOKEN` and `CLOUDFLARE_ACCOUNT_ID` for deployment. The Pages project is named `pdf-buddy`.

## 📱 PWA Installation

PDF Buddy can be installed as a Progressive Web App:

1. Open the app in your browser
2. Look for the "Install" prompt or use browser menu
3. Click "Install" to add it to your device
4. Launch it like a native app

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- [Syncfusion](https://www.syncfusion.com/) for the excellent PDF library
- [Flutter](https://flutter.dev/) team for the amazing framework
- [Material Design](https://material.io/) for the design system

## 📞 Support

If you encounter any issues or have questions:
1. Check the [Issues](../../issues) page
2. Create a new issue with detailed information
3. Include browser version and steps to reproduce

---

Made with ❤️ using Flutter Web
