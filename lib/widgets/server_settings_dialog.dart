import 'package:flutter/material.dart';

import '../core/constants.dart';
import '../services/api_service.dart';
import '../services/session_storage.dart';

/// Abre el diálogo para cambiar la dirección del backend.
Future<void> showServerSettingsDialog(BuildContext context) {
  return showDialog<void>(
    context: context,
    builder: (_) => const ServerSettingsDialog(),
  );
}

/// Permite apuntar la app a otro servidor sin recompilar, por ejemplo
/// http://192.168.1.10:3000/api cuando se prueba en un celular físico
/// conectado a la misma red Wi-Fi que el PC.
class ServerSettingsDialog extends StatefulWidget {
  const ServerSettingsDialog({super.key});

  @override
  State<ServerSettingsDialog> createState() => _ServerSettingsDialogState();
}

class _ServerSettingsDialogState extends State<ServerSettingsDialog> {
  late final TextEditingController _controller =
      TextEditingController(text: ApiService.baseUrl);
  bool _testing = false;
  String? _result;
  bool _success = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Limpia la URL: agrega http:// si falta y quita la barra final.
  String _normalizedUrl() {
    var url = _controller.text.trim();
    if (url.isEmpty) return Constants.defaultApiUrl;
    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      url = 'http://$url';
    }
    while (url.endsWith('/')) {
      url = url.substring(0, url.length - 1);
    }
    return url;
  }

  Future<void> _test() async {
    setState(() {
      _testing = true;
      _result = null;
    });
    final error = await ApiService.testConnection(_normalizedUrl());
    if (!mounted) return;
    setState(() {
      _testing = false;
      _success = error == null;
      _result = error ?? 'Conexión exitosa con el backend';
    });
  }

  Future<void> _save() async {
    final url = _normalizedUrl();
    ApiService.baseUrl = url;
    await SessionStorage().saveApiUrl(
      url == Constants.defaultApiUrl ? null : url,
    );
    if (!mounted) return;
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final result = _result;

    return AlertDialog(
      title: const Text('Servidor de la API'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Dirección del backend (Node.js + Express).\n'
              '• Emulador Android: http://10.0.2.2:3000/api\n'
              '• Celular físico: http://IP-de-tu-PC:3000/api',
              style: textTheme.bodySmall,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _controller,
              keyboardType: TextInputType.url,
              autocorrect: false,
              decoration: const InputDecoration(
                labelText: 'URL base',
                hintText: 'http://192.168.1.10:3000/api',
                prefixIcon: Icon(Icons.dns_outlined),
              ),
            ),
            if (_testing) ...[
              const SizedBox(height: 16),
              const LinearProgressIndicator(),
            ],
            if (result != null) ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  Icon(
                    _success
                        ? Icons.check_circle_rounded
                        : Icons.error_outline_rounded,
                    color: _success ? Colors.green : scheme.error,
                  ),
                  const SizedBox(width: 8),
                  Expanded(child: Text(result)),
                ],
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => _controller.text = Constants.defaultApiUrl,
          child: const Text('Restablecer'),
        ),
        TextButton(
          onPressed: _testing ? null : _test,
          child: const Text('Probar'),
        ),
        FilledButton(onPressed: _save, child: const Text('Guardar')),
      ],
    );
  }
}
