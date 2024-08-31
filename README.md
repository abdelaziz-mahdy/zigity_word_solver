# Zigity Word Solver

Zigity Word Solver is a Flutter application designed to find valid words based on a set of mandatory and available letters. This app can load words from a local asset file or an API, offering flexibility in how it retrieves word data.

## Features

- **Flexible Word Loading**: Load words from a local asset file or an API.
- **User Input**: Enter mandatory and available letters to find valid words.
- **Dynamic Word Display**: Results are displayed as chips with customizable borders.
- **Efficient Search**: Finds the top 10 valid words based on your input.

## Getting Started

Follow these steps to set up and run the Zigity Word Solver on your local machine.

### Prerequisites

- **Flutter**: Ensure you have Flutter installed. You can download it from the [official Flutter website](https://flutter.dev/docs/get-started/install).
- **Dart**: Flutter requires Dart. It is included with the Flutter SDK.

### Installation

1. **Clone the Repository**:

   ```bash
   git clone https://github.com/abdelaziz-mahdy/zigity_word_solver.git
   cd zigity_word_solver
   ```

2. **Install Dependencies**:
   Run the following command to install all necessary dependencies:

   ```bash
   flutter pub get
   ```

3. **Run the App**:
   Use the following command to run the app on your connected device or emulator:
   ```bash
   flutter run
   ```

### Project Structure

- **lib/**: Contains the main Dart files for the application.
  - **main.dart**: The entry point of the application.
  - **controllers/**: Includes the `WordController` class that handles the app's logic and state management.
  - **services/**: Contains services for loading word data and finding valid words.
    - **text_loader/**: Abstract class `TextLoader` and its implementations `ApiTextLoader` and `AssetTextLoader`.
    - **word_service.dart**: The service that uses `TextLoader` to load words and find valid words.

### How It Works

1. **Word Loading**:

   - The app uses the `TextLoader` interface to load words from either an asset file or an API.
   - `AssetTextLoader` loads words from a local asset file (e.g., `assets/popular.txt`).
   - `ApiTextLoader` loads words from a specified URL.

2. **User Input**:

   - Enter mandatory letters (must appear in each word).
   - Enter available letters (can be used to form words).

3. **Word Finding**:

   - The app finds the top 10 valid words using the mandatory and available letters provided by the user.

4. **Display**:
   - Results are shown as chips with colored borders, differentiating between mandatory and available letters.

### Customization

- **Switch Word Source**:

  - To switch between asset and API word sources, change the `WordService` initialization in `word_controller.dart`:

    ```dart
    // For asset loading
    final WordService _wordService = WordService(textLoader: AssetTextLoader(path: "assets/popular.txt"));

    // For API loading
    // final WordService _wordService = WordService(textLoader: ApiTextLoader(url: "your_api_url"));
    ```

- **Customize UI**:
  - Modify `main.dart` to change the UI components and their styling according to your needs.

## Contributing

Contributions are welcome! Feel free to submit a pull request or open an issue to discuss any changes.

## License

This project is licensed under the MIT License.
