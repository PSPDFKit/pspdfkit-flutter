// Copyright © 2018-2026 PSPDFKit GmbH. All rights reserved.
//
// THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
// AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
// UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
// This notice may not be removed from this file.

import 'package:flutter/material.dart';
import 'package:nutrient_flutter/bindings.dart';

import '../design/design.dart';

/// Password-protected document example (legacy row #15).
///
/// Two-step flow against the bundled `password.pdf` (password: `test123`):
///
/// 1. **Validate headlessly** — `adapter.openDocument(path, password: …)`
///    confirms the password and reads the page count. A wrong password
///    surfaces the platform's rejection (the error shape differs per
///    platform) instead of opening a viewer that can't render.
/// 2. **Open in the viewer** — the unlocked document is then displayed in a
///    [NutrientDocumentView] with `NutrientViewConfiguration(password: …)`,
///    which unlocks the encrypted document as the view loads on all three
///    platforms.
class PasswordProtectedExamplePage extends StatefulWidget {
  const PasswordProtectedExamplePage({super.key});

  @override
  State<PasswordProtectedExamplePage> createState() =>
      _PasswordProtectedExamplePageState();
}

class _PasswordProtectedExamplePageState
    extends State<PasswordProtectedExamplePage> {
  final TextEditingController _passwordController = TextEditingController(
    text: 'test123',
  );
  _PageState _state = const _Idle();
  int _viewGeneration = 0;

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _unlock() async {
    final password = _passwordController.text;
    setState(() => _state = const _Loading());

    try {
      final path = await CatalogDocuments.password(context);
      if (!mounted) return;

      // Validate the password headlessly first — a wrong password surfaces
      // a clear error here instead of a viewer that can't render.
      final doc = await Nutrient.openDocument(path, password: password);
      final int pageCount;
      try {
        pageCount = await doc.getPageCount();
      } finally {
        await doc.close();
      }

      if (!mounted) return;
      setState(() {
        _viewGeneration++;
        _state = _Unlocked(
          path: path,
          password: password,
          pageCount: pageCount,
        );
      });
    } on UnimplementedError catch (e) {
      if (!mounted) return;
      setState(() => _state = _Error('Not implemented: ${e.message ?? e}'));
    } catch (e) {
      if (!mounted) return;
      // A wrong password lands here — the error shape is platform-specific,
      // so present it as a "locked" outcome rather than a crash.
      setState(() => _state = _WrongPassword(e.toString()));
    }
  }

  void _lock() {
    setState(() => _state = const _Idle());
  }

  @override
  Widget build(BuildContext context) {
    final state = _state;
    return Scaffold(
      resizeToAvoidBottomInset: state is! _Unlocked,
      appBar: AppBar(
        title: const Text('Password Protected'),
        actions: [
          if (state is _Unlocked)
            IconButton(
              icon: const Icon(Icons.lock_outline),
              tooltip: 'Lock',
              onPressed: _lock,
            ),
        ],
      ),
      body: state is _Unlocked
          ? SafeArea(
              top: false,
              bottom: false,
              // The viewer unlocks the encrypted document itself via the
              // password on the view configuration.
              child: NutrientDocumentView(
                key: ValueKey('password-view-$_viewGeneration'),
                documentPath: state.path,
                configuration: NutrientViewConfiguration(
                  password: state.password,
                ),
              ),
            )
          : _buildForm(context),
      bottomNavigationBar: state is _Unlocked
          ? Material(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              child: SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: BrandSpacing.lg,
                    vertical: BrandSpacing.sm,
                  ),
                  child: Text(
                    'Unlocked · Page count: ${state.pageCount}',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: BrandColors.codeCoral,
                        ),
                  ),
                ),
              ),
            )
          : null,
    );
  }

  Widget _buildForm(BuildContext context) {
    final theme = Theme.of(context);
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(BrandSpacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Unlock the bundled password.pdf and open it in the viewer. '
              'The password is validated headlessly with '
              'adapter.openDocument(path, password: …), then the viewer '
              'unlocks it again via '
              'NutrientViewConfiguration(password: …). The correct password '
              'is test123 — try a wrong one to see the rejection path.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: BrandSpacing.lg),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: BrandSpacing.lg),
            FilledButton.icon(
              onPressed: _state is _Loading ? null : _unlock,
              icon: _state is _Loading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.lock_open_outlined),
              label: Text(_state is _Loading ? 'Unlocking…' : 'Unlock'),
            ),
            const SizedBox(height: BrandSpacing.xl),
            _FormStateView(state: _state),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Form-state views (idle / loading / errors — the unlocked state renders the
// viewer in the page body instead)
// ---------------------------------------------------------------------------

class _FormStateView extends StatelessWidget {
  final _PageState state;
  const _FormStateView({required this.state});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return switch (state) {
      _Idle() => Center(
          child: Text(
            'Locked — enter the password and tap Unlock',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
            ),
          ),
        ),
      _Loading() => const Center(child: CircularProgressIndicator()),
      _Unlocked() => const SizedBox.shrink(),
      _WrongPassword(:final detail) => Card(
          color: theme.colorScheme.errorContainer,
          child: Padding(
            padding: const EdgeInsets.all(BrandSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.lock_outline,
                      color: theme.colorScheme.onErrorContainer,
                    ),
                    const SizedBox(width: BrandSpacing.sm),
                    Text(
                      'Unlock failed',
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: theme.colorScheme.onErrorContainer,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: BrandSpacing.sm),
                Text(
                  detail,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onErrorContainer,
                  ),
                ),
              ],
            ),
          ),
        ),
      _Error(:final message) => Card(
          color: theme.colorScheme.errorContainer,
          child: Padding(
            padding: const EdgeInsets.all(BrandSpacing.lg),
            child: Text(
              message,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onErrorContainer,
              ),
            ),
          ),
        ),
    };
  }
}

// ---------------------------------------------------------------------------
// Page state ADT
// ---------------------------------------------------------------------------

sealed class _PageState {
  const _PageState();
}

class _Idle extends _PageState {
  const _Idle();
}

class _Loading extends _PageState {
  const _Loading();
}

class _Unlocked extends _PageState {
  final String path;
  final String password;
  final int pageCount;

  const _Unlocked({
    required this.path,
    required this.password,
    required this.pageCount,
  });
}

class _WrongPassword extends _PageState {
  final String detail;
  const _WrongPassword(this.detail);
}

class _Error extends _PageState {
  final String message;
  const _Error(this.message);
}
