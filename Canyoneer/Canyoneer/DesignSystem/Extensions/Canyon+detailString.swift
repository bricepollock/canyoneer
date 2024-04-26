//  Created by Brice Pollock for Canyoneer on 12/2/23

extension CanyonPreview {
    /// A String containing all the technical details for the canyon
    var technicalSummary: String {
        var summary = ""
        
        if let difficulty = technicalDifficulty, let water = waterDifficulty {
            summary.append("\(difficulty.text)\(water.text)")
        } else if let difficulty = technicalDifficulty {
            summary.append("\(difficulty.text)")
        } else if let water = waterDifficulty {
            summary.append("\(water.text)")
        }
        if let time = timeGrade {
            summary.append(" \(time.text)")
        }
        if let risk = risk {
            summary.append(" \(risk.rawValue)")
        }
        if let numRaps = numRappelsAsString {
            summary.append(" \(numRaps)")
        }
        if let max = maxRapLength {
            summary.append(" ↧\(Int(max.converted(to: .feet).value.rounded()))ft")
        }
        return summary
    }
}
