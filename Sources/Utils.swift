extension Collection where Iterator.Element: Equatable, SubSequence == Self {

    func trimLeft(target: Iterator.Element, maxCount: Int = -1) -> Self {
        if let first = self.first {
            if first == target {
                let sub = dropFirst()
                if maxCount == 1 {
                    return sub
                }
                let nextCount = maxCount > 1 ? maxCount - 1 : -1
                return sub.trimLeft(target, maxCount: nextCount)
            }
        }
        return self
    }

}

extension Collection where Iterator.Element: Equatable, SubSequence == Self, Index: BidirectionalIndex {

    func trimRight(target: Iterator.Element, maxCount: Int = -1) -> Self {
        if let last = self.last {
            if last == target {
                let sub = dropLast()
                if maxCount == 1 {
                    return sub
                }
                let nextCount = maxCount > 1 ? maxCount - 1 : -1
                return sub.trimRight(target, maxCount: nextCount)
            }
        }
        return self
    }

}

extension String {

    func chomp() -> String {
        let spaces = [Character(UnicodeScalar(10)), Character(UnicodeScalar(13))]
        return String(spaces.reduce(self.characters) { $0.trimRight($1) })
    }

}
