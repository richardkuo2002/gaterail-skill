# Testing Patterns

Default patterns that illustrate the principles in `test-driven-development`.
They're a starting point, not a mandate — adapt them to what a repository's
stack and existing test suite already do.

## Regression test first, for bugs

Reproduce the bug with a failing test before touching the fix. The test
proves the bug exists, then proves it's gone.

```js
// Bug: "Completing a task doesn't update the completedAt timestamp"
it('sets completedAt when task is completed', async () => {
  const task = await createTask({ title: 'test' });
  const completed = await taskService.completeTask(task.id);
  expect(completed.status).toBe('completed');
  expect(completed.completedAt).toBeInstanceOf(Date); // fails first, then passes
});
```

## Arrange / Act / Assert

Structure each test in three clearly separated parts. Don't interleave setup,
the call under test, and assertions.

```js
it('rejects a withdrawal larger than the balance', () => {
  // Arrange
  const account = new Account({ balance: 100 });

  // Act
  const result = account.withdraw(150);

  // Assert
  expect(result.ok).toBe(false);
  expect(account.balance).toBe(100);
});
```

## Behavior-oriented, not implementation-coupled

Assert on observable outcomes (return value, state, side effect), not on
internal calls or private structure. A test that breaks when you rename a
private helper — without changing behavior — is coupled to the wrong thing.

```js
// Coupled to implementation — breaks on a harmless internal refactor
expect(account._computeBalance).toHaveBeenCalledTimes(1);

// Coupled to behavior — survives internal refactors
expect(account.balance).toBe(100);
```

## Boundary and error-path coverage

Every test suite for non-trivial logic should cover, not just the happy path:

- Empty / zero / null / undefined input
- The smallest and largest valid values
- One step past a valid boundary (off-by-one)
- The documented error path (invalid input, network failure, timeout)

## Deterministic fixtures and test isolation

- No test depends on another test's side effects or run order.
- No test depends on wall-clock time, network access, or ambient global
  state unless that's exactly what's under test — and then it's mocked or
  injected, not incidental.
- Shared fixtures are built fresh per test (or reset in `beforeEach`), not
  mutated and reused across tests.

## Test naming states expected behavior

Name the test after what should happen, not after the method being called.

```js
// Says what was called, not what's expected
it('testWithdraw', () => { ... });

// States the expected behavior
it('rejects a withdrawal larger than the balance', () => { ... });
```

## See Also

The examples above use Jest-style syntax for concreteness; the principles
(regression-first, AAA, behavior over implementation, boundary coverage,
isolation, descriptive naming) transfer to any test framework or language.
