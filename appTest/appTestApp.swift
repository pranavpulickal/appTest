import SwiftUI

// Vehicle model
struct Vehicle: Identifiable, Codable {
    let id = UUID()
    let year: Int
    let manufacturer: String
    let model: String
    let trim: String // New field for Trim
    let configuration: String
    let cityMPG: Int
    let highwayMPG: Int
    let combinedMPG: Int
    let annualFuelCost: String
    let ghgRating: Int
    let notes: String?

    enum CodingKeys: String, CodingKey {
        case year = "Year"
        case manufacturer = "Manufacturer"
        case model = "Model"
        case trim = "Trim" // Maps to the "Trim" key in the JSON
        case configuration = "Configuration (trans, eng size, cyl)"
        case cityMPG = "City MPG"
        case highwayMPG = "Highway MPG"
        case combinedMPG = "Combined MPG"
        case annualFuelCost = "Annual Fuel Cost"
        case ghgRating = "GHG Rating"
        case notes = "Notes"
    }
}

// Main starting menu with the Toyota logo
struct MainMenuView: View {
    @State private var navigateToContent = false

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Toyota 3D Logo
                Image("Toyota3d2c") // Reference the image in Assets
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 200)
                    .padding()

                // Welcome Text
                Text("Welcome to Toyota Fuel Economy App")
                    .font(.title)
                    .multilineTextAlignment(.center)
                    .padding()

                // Button to proceed to the main app
                NavigationLink(destination: ContentView(), isActive: $navigateToContent) {
                    Button(action: {
                        navigateToContent = true
                    }) {
                        Text("Enter App")
                            .font(.headline)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.red)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                            .padding(.horizontal)
                    }
                }
            }
            .padding()
            .navigationBarHidden(true)
        }
    }
}

// Main ContentView with dynamic year handling
struct ContentView: View {
    @State private var vehicles: [Vehicle] = []

    var years: [Int] {
        Array(Set(vehicles.map { $0.year })).sorted()
    }

    var body: some View {
        NavigationView {
            VStack {
                // Toyota Logo
                Image("Toyota3d2c") // Reference the logo in Assets
                    .resizable()
                    .scaledToFit()
                    .frame(width: 150, height: 150)
                    .padding(.top)

                // Year Selection List
                List(years, id: \.self) { year in
                    NavigationLink(destination: YearView(year: year, vehicles: vehicles.filter { $0.year == year })) {
                        Text("Year \(year.description)") // Explicitly use .description to avoid formatting
                            .font(.headline)
                    }
                }
                .navigationTitle("Select a Year")
                .onAppear {
                    loadVehicleData()
                }
            }
        }
    }

    private func loadVehicleData() {
        guard let url = Bundle.main.url(forResource: "toyotadata", withExtension: "json") else {
            print("Failed to locate toyotadata.json in bundle.")
            return
        }

        do {
            let data = try Data(contentsOf: url)
            vehicles = try JSONDecoder().decode([Vehicle].self, from: data)
            print("Data loaded successfully: \(vehicles)")
        } catch {
            print("Failed to load or decode data: \(error)")
        }
    }
}

// View for Models within a Year
struct YearView: View {
    let year: Int
    let vehicles: [Vehicle]

    var models: [String] {
        Array(Set(vehicles.map { $0.model })).sorted()
    }

    var body: some View {
        List(models, id: \.self) { model in
            NavigationLink(destination: ModelView(model: model, vehicles: vehicles.filter { $0.model == model })) {
                Text(model)
                    .font(.headline)
            }
        }
        .navigationTitle("Year \(year.description)") // Ensures no commas in title
    }
}

// View for Trims within a Model
struct ModelView: View {
    let model: String
    let vehicles: [Vehicle]

    var trims: [String] {
        Array(Set(vehicles.map { $0.trim })).sorted()
    }

    // Calculate average statistics for the model
    var averageCityMPG: Double {
        let total = vehicles.reduce(0) { $0 + $1.cityMPG }
        return Double(total) / Double(vehicles.count)
    }

    var averageHighwayMPG: Double {
        let total = vehicles.reduce(0) { $0 + $1.highwayMPG }
        return Double(total) / Double(vehicles.count)
    }

    var averageCombinedMPG: Double {
        let total = vehicles.reduce(0) { $0 + $1.combinedMPG }
        return Double(total) / Double(vehicles.count)
    }

    // Check if any vehicle in this model is an FCV
    var isFCV: Bool {
        vehicles.contains { $0.notes?.contains("FCV") == true }
    }

    var body: some View {
        VStack {
            // Display model image
            Image(model.lowercased()) // Dynamically matches model name (case insensitive)
                .resizable()
                .scaledToFit()
                .frame(width: 200, height: 200)
                .cornerRadius(10)
                .padding()

            // Display average stats
            VStack(alignment: .leading, spacing: 10) {
                Text("Average Statistics for \(model)")
                    .font(.headline)
                    .padding(.bottom, 5)

                // Conditionally show MPG or MPGe
                Text("City MPG\(isFCV ? " Equivalent (MPGe)" : ""): \(String(format: "%.2f", averageCityMPG))")
                Text("Highway MPG\(isFCV ? " Equivalent (MPGe)" : ""): \(String(format: "%.2f", averageHighwayMPG))")
                Text("Combined MPG\(isFCV ? " Equivalent (MPGe)" : ""): \(String(format: "%.2f", averageCombinedMPG))")
            }
            .padding()
            .background(Color(UIColor.systemGroupedBackground))
            .cornerRadius(10)
            .padding()

            // Display list of trims
            List(trims, id: \.self) { trim in
                NavigationLink(destination: TrimView(trim: trim, vehicles: vehicles.filter { $0.trim == trim })) {
                    Text(trim.isEmpty ? "Base Trim" : trim) // Show "Base Trim" if trim is empty
                        .font(.headline)
                }
            }
        }
        .navigationTitle(model)
    }
}

// View for a specific Trim with all details
struct TrimView: View {
    let trim: String
    let vehicles: [Vehicle]

    var body: some View {
        VStack {
            // Banner at the top
            Text("Detailed Info")
                .font(.headline)
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.green.opacity(0.8)) // Background color for the banner
                .foregroundColor(.white)

            // List of detailed vehicle information
            List(vehicles) { vehicle in
                VStack(alignment: .leading, spacing: 8) {
                    Text("Manufacturer: \(vehicle.manufacturer)")
                        .font(.headline)
                    Text("Configuration: \(vehicle.configuration)")
                        .font(.subheadline)

                    // Conditionally display MPG or mpgE
                    if let notes = vehicle.notes, notes.contains("FCV") {
                        Text("City MPG Equivalent: \(vehicle.cityMPG) MPGe")
                            .font(.subheadline)
                        Text("Highway MPG Equivalent: \(vehicle.highwayMPG) MPGe")
                            .font(.subheadline)
                        Text("Combined MPG Equivalent: \(vehicle.combinedMPG) MPGe")
                            .font(.subheadline)
                    } else {
                        Text("City MPG: \(vehicle.cityMPG)")
                            .font(.subheadline)
                        Text("Highway MPG: \(vehicle.highwayMPG)")
                            .font(.subheadline)
                        Text("Combined MPG: \(vehicle.combinedMPG)")
                            .font(.subheadline)
                    }

                    Text("Annual Fuel Cost: \(vehicle.annualFuelCost)")
                        .font(.subheadline)
                    Text("GHG Rating: \(vehicle.ghgRating)")
                        .font(.subheadline)

                    if let notes = vehicle.notes, !notes.isEmpty {
                        Text("Notes: \(notes)")
                            .font(.footnote)
                            .foregroundColor(.gray)
                    }
                }
                .padding(.vertical, 8)
            }
        }
        .navigationTitle(trim.isEmpty ? "Base Trim" : trim)
    }
}

@main
struct ToyotaFuelEconomyApp: App {
    var body: some Scene {
        WindowGroup {
            MainMenuView() // Start with the MainMenuView
        }
    }
}
 
