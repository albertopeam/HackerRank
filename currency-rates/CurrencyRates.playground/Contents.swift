import Foundation

/*
 * Complete the 'findRateAndRoute' function below.
 *
 * The function accepts:
 *  - currencyPair: a pair of ISO 4217 currency codes, e.g. USDEUR
 *  - rates: a dictionary of currency pairs and their respective exchange rate, e.g.
 *    USDEUR -> 0.89
 *    RUBDKK -> 0.083
 *    ...
 *
 * The function is expected to return, in a (Decimal, String) pair:
 *  1. exchange rate from left to right currency in currencyPair
 *  2. shortest route between currencies to make the exchange, formed concatenating currency codes (e.g. USDEURRUB)
 */
func findRateAndRoute(for currencyPair: String, rates: [String: Decimal]) -> (rate: Decimal, route: String) {
    if let directPair = rates[currencyPair] {
        return (directPair, currencyPair)
    } else {
        let solutions = possibleSolutions(for: currencyPair, rates: rates)
        if !solutions.isEmpty {
            let solution = findSolution(for: currencyPair, solutions: solutions)
            if !solution.isEmpty {
                let rate = rate(for: solution, rates: rates)
                return (rate, currencyPair)
            }
        }
        return (0, "")
    }
}

/// find all the possible solutions for the shortest path.
private func possibleSolutions(for currencyPair: String, rates: [String: Decimal]) -> [[CurrencyPair]] {
    let targetSrc = currencyPair.src
    let targetDst = currencyPair.dst
    var destinationPairs = rates.keys.filter { $0.dst == targetDst }
    var solutions: [[CurrencyPair]] = .init()
    solutions.append(destinationPairs)
    while solutions.first?.first(where: { $0.src == targetSrc }) == nil {
        var iterationPairs: [CurrencyPair] = .init()
        destinationPairs.forEach { currencyPair in
            let matches = rates.keys.filter { $0.dst == currencyPair.src }
            if !matches.isEmpty {
                iterationPairs.append(contentsOf: matches)
            }
        }
        if iterationPairs.isEmpty {
            break // no solution
        } else {
            destinationPairs = iterationPairs
            solutions.insert(destinationPairs, at: 0)
        }
    }
    let onlyDestinationCount = 1
    if solutions.count == onlyDestinationCount {
        return [[]]
    }
    if let first = solutions.first {
        let filteredFirst = first.filter({ $0.src == currencyPair.src })
        if filteredFirst.count != first.count {
            solutions.remove(at: 0)
            solutions.insert(filteredFirst, at: 0)
        }
    }
    return solutions
}

/// find a solution from the possible solutions array. if no solution then return empty
private func findSolution(for currencyPair: String, solutions: [[CurrencyPair]]) -> [CurrencyPair] {
    var solution: [CurrencyPair] = .init()
    if let first = solutions.first?.first {
        solution.append(first)
        var dst = first.dst
        solutions.dropFirst().forEach { pairs in
            if let pair = pairs.first(where: { $0.src == dst }) {
                solution.append(pair)
                dst = pair.dst
            }
        }
    }
    if solution.first?.src == currencyPair.src && solution.last?.dst == currencyPair.dst {
        return solution
    } else {
        return []
    }
}

private func rate(for solution: [CurrencyPair], rates: [String: Decimal]) -> Decimal {
    var acc: Decimal = 1
    solution.forEach { item in
        if let rate = rates[item] {
            acc = acc * rate
        }
    }
    return acc
}

typealias CurrencyPair = String

extension CurrencyPair {
    /// destination currency
    var dst: String {
        let dstStartIndex = index(startIndex, offsetBy: 3)
        let destEndIndex = index(endIndex, offsetBy: -1)
        return String(self[dstStartIndex...destEndIndex])
    }
    
    /// source currency
    var src: String {
        let srcStartIndex = startIndex
        let srcEndIndex = index(startIndex, offsetBy: 2)
        return String(self[srcStartIndex...srcEndIndex])
    }
}

let rates = ["USDYEN": Decimal(138.81), "USDEUR": Decimal(0.96), "GBPRUB": Decimal(71.68), "USDGBP": Decimal(0.84), "GBPEUR": Decimal(1.14), "EURRUB": Decimal(62.77)]
print(findRateAndRoute(for: "USDRUB", rates: rates))

/*
2 possible solutions:
["USDGBP", "GBPRUB"] -> (rate: 60.2112000000000086016, route: "USDRUB")
["USDEUR", "EURRUB"] -> (rate: 60.2592, route: "USDRUB")
*/
