import Observation

/// Helps implement the conformance to the ``Reducer`` protocol for a type.
///
/// See the article <doc:Reducers> for more information about the macro and ``Reducer`` protocol.
@attached(
  member,
  names:
    named(State),
  named(Action),
  named(init),
  named(body),
  named(CaseScope),
  named(scope)
)
@attached(memberAttribute)
@attached(extension, conformances: Reducer, CaseReducer)
public macro Reducer() =
  #externalMacro(
    module: "ComposableArchitectureMacros", type: "ReducerMacro"
  )

/// An overload of ``Reducer()`` that takes a description of protocol conformances to synthesize on
/// the State and Action types
///
/// See the article <doc:Reducers> for more information about the macro and ``Reducer`` protocol, in
/// particular the section
/// <doc:Reducers#Synthesizing-protocol-conformances-on-State-and-Action>.
@attached(
  member,
  names:
    named(State),
  named(Action),
  named(init),
  named(body),
  named(CaseScope),
  named(scope)
)
@attached(memberAttribute)
@attached(extension, conformances: Reducer, CaseReducer)
public macro Reducer(state: _SynthesizedConformance..., action: _SynthesizedConformance...) =
  #externalMacro(
    module: "ComposableArchitectureMacros", type: "ReducerMacro"
  )

/// A description of a protocol conformance to synthesize on the State and Action types generated by
/// the ``Reducer()`` macro.
///
/// See <doc:Reducers#Synthesizing-protocol-conformances-on-State-and-Action> for more information.
@_documentation(visibility:public)
public struct _SynthesizedConformance {}

extension _SynthesizedConformance {
  /// Extends the `State` or `Action` types that ``Reducer()`` creates with the `Codable`
  /// protocol.
  public static let codable = Self()
  /// Extends the `State` or `Action` types that ``Reducer()`` creates with the `Decodable`
  /// protocol.
  public static let decodable = Self()
  /// Extends the `State` or `Action` types that ``Reducer()`` creates with the `Encodable`
  /// protocol.
  public static let encodable = Self()
  /// Extends the `State` or `Action` types that ``Reducer()`` creates with the `Equatable`
  /// protocol.
  public static let equatable = Self()
  /// Extends the `State` or `Action` types that ``Reducer()`` creates with the `Hashable`
  /// protocol.
  public static let hashable = Self()
  /// Extends the `State` or `Action` types that ``Reducer()`` creates with the `Sendable`
  /// protocol.
  public static let sendable = Self()
}

/// Marks the case of an enum reducer as holding onto "ephemeral" state.
///
/// Apply this reducer to any cases of an enum reducer that holds onto state conforming to the
/// ``ComposableArchitecture/_EphemeralState`` protocol, such as `AlertState` and
/// `ConfirmationDialogState`:
///
/// ```swift
/// @Reducer
/// enum Destination {
///   @ReducerCaseEphemeral
///   case alert(AlertState<Alert>)
///   // ...
///
///   enum Alert {
///     case saveButtonTapped
///     case discardButtonTapped
///   }
/// }
/// ```
@attached(peer, names: named(_))
public macro ReducerCaseEphemeral() =
  #externalMacro(module: "ComposableArchitectureMacros", type: "ReducerCaseEphemeralMacro")

/// Marks the case of an enum reducer as "ignored", and as such will not compose the case's domain
/// into the rest of the reducer besides state.
///
/// Apply this macro to cases that do not hold onto reducer features, and instead hold onto plain
/// data that needs to be passed to a child view.
///
/// ```swift
/// @Reducer
/// enum Destination {
///   @ReducerCaseIgnored
///   case meeting(id: Meeting.ID)
///   // ...
/// }
/// ```
@attached(peer, names: named(_))
public macro ReducerCaseIgnored() =
  #externalMacro(module: "ComposableArchitectureMacros", type: "ReducerCaseIgnoredMacro")

/// Defines and implements conformance of the Observable protocol.
@attached(extension, conformances: Observable, ObservableState)
@attached(member, names: named(_$id), named(_$observationRegistrar), named(_$willModify))
@attached(memberAttribute)
public macro ObservableState() =
  #externalMacro(module: "ComposableArchitectureMacros", type: "ObservableStateMacro")

@attached(accessor, names: named(init), named(get), named(set))
@attached(peer, names: prefixed(_))
public macro ObservationStateTracked() =
  #externalMacro(module: "ComposableArchitectureMacros", type: "ObservationStateTrackedMacro")

@attached(accessor, names: named(willSet))
public macro ObservationStateIgnored() =
  #externalMacro(module: "ComposableArchitectureMacros", type: "ObservationStateIgnoredMacro")

/// Wraps a property with ``PresentationState`` and observes it.
///
/// Use this macro instead of ``PresentationState`` when you adopt the ``ObservableState()``
/// macro, which is incompatible with property wrappers like ``PresentationState``.
@attached(accessor, names: named(init), named(get), named(set))
@attached(peer, names: prefixed(`$`), prefixed(_))
public macro Presents() =
  #externalMacro(module: "ComposableArchitectureMacros", type: "PresentsMacro")

/// Provides a view with access to a feature's ``ViewAction``s.
///
/// If you want to restrict what actions can be sent from the view you can use this macro along the
/// ``ViewAction`` protocol. You start by conforming your reducer's `Action` enum to the
/// ``ViewAction`` protocol, and moving view-specific actions to its own inner enum:
///
/// ```swift
/// @Reducer
/// struct Feature {
///   struct State { /* ... */ }
///   enum Action: ViewAction {
///     case loginResponse(Bool)
///     case view(View)
///
///     enum View {
///       case loginButtonTapped
///     }
///   }
///   // ...
/// }
/// ```
///
/// Then you can apply the ``ViewAction(for:)`` macro to your view by specifying the type of the
/// reducer that powers the view:
///
/// ```swift
/// @ViewAction(for: Feature.self)
/// struct FeatureView: View {
///   let store: StoreOf<Feature>
///   // ...
/// }
/// ```
///
/// The macro does two things:
///
/// * It adds a `send` method to the view that you can use instead of `store.send`. This allows you
///   to send view actions more simply, without wrapping the action in `.view(…)`:
///   ```diff
///    Button("Login") {
///   -  store.send(.view(.loginButtonTapped))
///   +  send(.loginButtonTapped)
///    }
///   ```
/// * It creates warning diagnostics if you try sending actions through `store.send` rather than
///   using the `send` method on the view:
///   ```swift
///   Button("Login") {
///     store.send(.view(.loginButtonTapped))
///   //┬─────────
///   //╰─ ⚠️ Do not use 'store.send' directly when using '@ViewAction'
///   }
///   ```
@attached(extension, conformances: ViewActionSending)
public macro ViewAction<R: Reducer>(for: R.Type) =
  #externalMacro(
    module: "ComposableArchitectureMacros", type: "ViewActionMacro"
  ) where R.Action: ViewAction
