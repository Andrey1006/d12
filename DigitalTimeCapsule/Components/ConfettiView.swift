import SwiftUI

struct ConfettiPiece: Identifiable {
    let id = UUID()
    let x = Double.random(in: 0...1)
    let size = CGFloat.random(in: 6...12)
    let color = [Color.orange, Color.pink, Color.teal, Color.yellow, Color.purple, Color.green].randomElement()!
    let rotationStart = Double.random(in: 0...180)
    let rotationEnd = Double.random(in: 240...900)
    let duration = Double.random(in: 1.6...2.8)
    let delay = Double.random(in: 0...0.5)
}

struct ConfettiView: View {
    private let pieces: [ConfettiPiece]
    @State private var animate = false

    init(count: Int = 70) {
        pieces = (0..<count).map { _ in ConfettiPiece() }
    }

    var body: some View {
        GeometryReader { geo in
            ZStack {
                ForEach(pieces) { piece in
                    RoundedRectangle(cornerRadius: 1.5)
                        .fill(piece.color)
                        .frame(width: piece.size, height: piece.size * 0.55)
                        .rotationEffect(.degrees(animate ? piece.rotationEnd : piece.rotationStart))
                        .position(x: piece.x * geo.size.width,
                                  y: animate ? geo.size.height + 50 : -50)
                        .opacity(animate ? 0 : 1)
                        .animation(.easeIn(duration: piece.duration).delay(piece.delay), value: animate)
                }
            }
            .onAppear { animate = true }
        }
        .allowsHitTesting(false)
    }
}
