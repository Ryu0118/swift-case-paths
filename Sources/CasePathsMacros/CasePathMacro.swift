import SwiftSyntax
import SwiftSyntaxMacros

public struct CasePathMacro: ExpressionMacro {
  public static func expansion(
    of node: some FreestandingMacroExpansionSyntax,
    in context: some MacroExpansionContext
  ) throws -> ExprSyntax {
    guard let argument = node.argumentList.first?.expression.as(KeyPathExprSyntax.self)
    else {
      throw CustomError.message("#casePath requires a @CasePathable enum key path")
    }

    guard argument.components.filter({ $0.period != nil }).count == 1
    else {
      // TODO: Point to second period
      throw CustomError.message("#casePath requires a @CasePathable enum key path")
    }

    guard
      let identifier = argument.components
        .compactMap({ $0.component.as(KeyPathPropertyComponentSyntax.self)?.declName.baseName })
        .first
    else {
      throw CustomError.message("#casePath requires a @CasePathable enum key path")
    }

    // TODO: Can/should we support #casePath(\.foo?.bar) if this compile?
    //     CasePath(embed: { .foo(.bar($0)) }, extract: \.foo?.bar)
    return "CasePath(embed: { .\(identifier)($0) }, extract: \(argument))"
  }
}
