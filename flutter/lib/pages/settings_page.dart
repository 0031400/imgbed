import 'package:flutter/material.dart';
import '../services/settings_service.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final _formKey = GlobalKey<FormState>();
  final _uploadUrlController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _urlPrefixController = TextEditingController();
  final _settings = SettingsService();

  @override
  void initState() {
    super.initState();
    _uploadUrlController.text = _settings.uploadUrl;
    _usernameController.text = _settings.username;
    _passwordController.text = _settings.password;
    _urlPrefixController.text = _settings.urlPrefix;
  }

  @override
  void dispose() {
    _uploadUrlController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _urlPrefixController.dispose();
    super.dispose();
  }

  void _saveSettings() async {
    if (_formKey.currentState!.validate()) {
      await _settings.saveSettings(
        uploadUrl: _uploadUrlController.text,
        username: _usernameController.text,
        password: _passwordController.text,
        urlPrefix: _urlPrefixController.text,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('设置已保存')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('设置'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _uploadUrlController,
                decoration: const InputDecoration(
                  labelText: '上传地址',
                  hintText: 'https://imgbed.com/upload',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '请输入上传地址';
                  }
                  final uri = Uri.tryParse(value);
                  if (uri == null || !uri.hasScheme) {
                    return '请输入有效的URL';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _urlPrefixController,
                decoration: const InputDecoration(
                  labelText: '链接前缀',
                  hintText: 'https://imgbed.com/i/',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '请输入链接前缀';
                  }
                  final uri = Uri.tryParse(value);
                  if (uri == null || !uri.hasScheme) {
                    return '请输入有效的URL';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _usernameController,
                decoration: const InputDecoration(
                  labelText: '用户名',
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(
                  labelText: '密码',
                ),
                obscureText: true,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _saveSettings,
                child: const Text('保存设置'),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 