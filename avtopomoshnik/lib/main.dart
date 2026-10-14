import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:convert';

// ============================================================================
//   АВТОПОМОЩНИК — весь код приложения в одном файле
//   1. ВСТАВЬТЕ свои партнёрские ссылки ниже (PartnerLinks)
//   2. Для проверки штрафов подключите платный API агрегатора (см. README)
// ============================================================================

// >>>>>>>>>>>>>>>>>>>>>>>> ПАРТНЁРСКИЕ ССЫЛКИ <<<<<<<<<<<<<<<<<<<<<<
// Замените ссылки на свои партнёрские (CPA). Все переходы идут через них.
class PartnerLinks {
  static const String osago         = 'https://ВАША_ССЫЛКА_осаго';
  static const String kreditAvto    = 'https://ВАША_ССЫЛКА_кредит_на_авто';
  static const String proverkaVin   = 'https://ВАША_ССЫЛКА_проверка_авто';
  static const String shtrafyOplata = 'https://ВАША_ССЫЛКА_оплата_штрафов';
  static const String shiny         = 'https://ВАША_ССЫЛКА_шины';
}
// >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>><<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

Future<void> openLink(String url) async {
  final uri = Uri.parse(url);
  if (await canLaunchUrl(uri)) {
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}

void main() => runApp(const AvtoApp());

class AvtoApp extends StatelessWidget {
  const AvtoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Автопомощник',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1E63A8),
          primary: const Color(0xFF1E63A8),
          secondary: const Color(0xFFF57C00),
        ),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(centerTitle: true),
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(),
          isDense: true,
        ),
      ),
      home: const HomePage(),
    );
  }
}

// ============================================================================
//  ГЛАВНЫЙ ЭКРАН
// ============================================================================
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final items = <_MenuItem>[
      _MenuItem('Штрафы ГИБДД', Icons.receipt_long, Colors.red,
          'Проверка штрафов по госномеру и СТС'),
      _MenuItem('Транспортный налог', Icons.account_balance, Colors.blue,
          'Расчёт налога по региону и мощности'),
      _MenuItem('ОСАГО-калькулятор', Icons.calculate, Colors.green,
          'Примерная стоимость полиса'),
      _MenuItem('Мой гараж', Icons.garage, Colors.orange,
          'Напоминания: ТО, страховка, переобувка'),
      _MenuItem('Партнёрские предложения', Icons.local_offer, Colors.purple,
          'ОСАГО, кредит, проверка авто, шины'),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Автопомощник')),
      body: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: items.length,
        itemBuilder: (context, i) {
          final it = items[i];
          return Card(
            elevation: 1,
            margin: const EdgeInsets.only(bottom: 10),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: it.color.withOpacity(0.12),
                child: Icon(it.icon, color: it.color),
              ),
              title: Text(it.title,
                  style: const TextStyle(fontWeight: FontWeight.w600)),
              subtitle: Text(it.subtitle),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Widget page;
                switch (i) {
                  case 0:
                    page = const ShtrafyPage();
                    break;
                  case 1:
                    page = const NalogPage();
                    break;
                  case 2:
                    page = const OsagoPage();
                    break;
                  case 3:
                    page = const GarazhPage();
                    break;
                  default:
                    page = const PartnerPage();
                }
                Navigator.push(
                    context, MaterialPageRoute(builder: (_) => page));
              },
            ),
          );
        },
      ),
    );
  }
}

class _MenuItem {
  final String title, subtitle;
  final IconData icon;
  final Color color;
  _MenuItem(this.title, this.icon, this.color, this.subtitle);
}

// ============================================================================
//  1. ШТРАФЫ ГИБДД
// ============================================================================
class ShtrafyPage extends StatefulWidget {
  const ShtrafyPage({super.key});
  @override
  State<ShtrafyPage> createState() => _ShtrafyPageState();
}

class _ShtrafyPageState extends State<ShtrafyPage> {
  final _plate = TextEditingController();
  final _sts = TextEditingController();
  bool _loading = false;

  Future<void> _check() async {
    if (_plate.text.trim().isEmpty || _sts.text.trim().isEmpty) {
      _show('Заполните госномер и номер СТС');
      return;
    }
    setState(() => _loading = true);
    await Future.delayed(const Duration(seconds: 1)); // имитация запроса

    // TODO(владелец): подключите платный API агрегатора штрафов
    // (поищите "API проверки штрафов ГИБДД", цена обычно 1-3 ₽/запрос).
    // Замените этот диалог на реальный запрос: POST госномер + СТС,
    // получите JSON со списком штрафов и покажите его вместо заглушки.

    if (!mounted) return;
    setState(() => _loading = false);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Демо-режим'),
        content: const Text(
            'Проверка штрафов появится после подключения платного API агрегатора '
            '(см. раздел «Штрафы» в README).\n\n'
            'Пока пользователи могут оплатить штрафы со скидкой по кнопке ниже.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Понятно')),
        ],
      ),
    );
  }

  void _show(String m) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m)));

  @override
  void dispose() {
    _plate.dispose();
    _sts.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Штрафы ГИБДД')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: _plate,
            textCapitalization: TextCapitalization.characters,
            decoration: const InputDecoration(
                labelText: 'Госномер', hintText: 'А123БВ77'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _sts,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
                labelText: 'Номер СТС', hintText: '12 34 567890'),
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: _loading ? null : _check,
            icon: _loading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.search),
            label: Text(_loading ? 'Проверяем...' : 'Проверить штрафы'),
          ),
          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 12),
          Card(
            color: Colors.green.shade50,
            child: ListTile(
              leading: const Icon(Icons.discount, color: Colors.green),
              title: const Text('Оплатить штрафы со скидкой 50%'),
              subtitle: const Text('Переход в сервис оплаты по партнёрской ссылке'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => openLink(PartnerLinks.shtrafyOplata),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
//  2. ТРАНСПОРТНЫЙ НАЛОГ
// ============================================================================
class NalogPage extends StatefulWidget {
  const NalogPage({super.key});
  @override
  State<NalogPage> createState() => _NalogPageState();
}

class _NalogPageState extends State<NalogPage> {
  // Ставки за 1 л.с. для легковых 100–150 л.с. (примерные, уточните актуальные!)
  static const Map<String, double> _regions = {
    'Москва': 35,
    'Московская область': 34,
    'Санкт-Петербург': 35,
    'Татарстан': 35,
    'Краснодарский край': 30,
    'Свердловская область': 30,
    'Новосибирская область': 30,
    'Регионы РФ (средняя)': 25,
  };

  String _region = 'Москва';
  final _hp = TextEditingController(text: '120');
  double _months = 12;

  double? get _result {
    final hp = double.tryParse(_hp.text.trim());
    if (hp == null || hp <= 0) return null;
    final rate = _regions[_region] ?? 25;
    return rate * hp * _months / 12;
  }

  @override
  void dispose() {
    _hp.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Транспортный налог')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          DropdownButtonFormField<String>(
            value: _region,
            decoration: const InputDecoration(labelText: 'Регион'),
            items: _regions.keys
                .map((r) => DropdownMenuItem(value: r, child: Text(r)))
                .toList(),
            onChanged: (v) => setState(() => _region = v ?? _region),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _hp,
            keyboardType: TextInputType.number,
            decoration:
                const InputDecoration(labelText: 'Мощность, л.с.', hintText: '120'),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 12),
          Text('Месяцев владения в году: ${_months.round()}'),
          Slider(
            value: _months,
            min: 1,
            max: 12,
            divisions: 11,
            onChanged: (v) => setState(() => _months = v),
          ),
          const SizedBox(height: 16),
          Card(
            color: Colors.blue.shade50,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Примерный налог за год:',
                      style: TextStyle(fontSize: 16)),
                  const SizedBox(height: 6),
                  Text(
                    _result == null
                        ? '—'
                        : '${_result!.toStringAsFixed(0)} ₽',
                    style: const TextStyle(
                        fontSize: 32, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Расчёт ориентировочный, по базовым ставкам. Точные ставки зависят от '
            'региона, мощности и льгот — проверяйте на сайте ФНС.',
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
//  3. ОСАГО-КАЛЬКУЛЯТОР
// ============================================================================
class OsagoPage extends StatefulWidget {
  const OsagoPage({super.key});
  @override
  State<OsagoPage> createState() => _OsagoPageState();
}

class _OsagoPageState extends State<OsagoPage> {
  // Упрощённые коэффициенты. Реальные берутся из справочников ЦБ РФ
  // и обновляются ежегодно — уточните перед публикацией.
  static const _kbm = {
    'Класс 1 (2.45)': 2.45, 'Класс 2 (2.3)': 2.3, 'Класс 3 (1.55)': 1.55,
    'Класс 4 (1.4)': 1.4, 'Класс 5 (1.0)': 1.0, 'Класс 6 (0.95)': 0.95,
    'Класс 7 (0.9)': 0.9, 'Класс 8 (0.85)': 0.85, 'Класс 10 (0.74)': 0.74,
    'Класс 13 (0.54)': 0.54, 'Класс 15 (0.46)': 0.46,
  };

  String _kbmSelected = 'Класс 5 (1.0)';
  double _age = 30;      // возраст
  double _experience = 5; // стаж
  double _power = 120;    // л.с.

  // Примерный средний базовый тариф (уточните актуальный)
  static const double _tb = 4600;

  double get _kvs {
    if (_age < 22 && _experience < 3) return 1.87;
    if (_age < 22) return 1.72;
    if (_experience < 3) return 1.56;
    if (_age < 30 && _experience < 5) return 1.22;
    if (_age < 45 && _experience < 10) return 1.09;
    return 1.01;
  }

  double get _km {
    if (_power < 70) return 0.6;
    if (_power < 100) return 1.1;
    if (_power < 120) return 1.2;
    if (_power < 150) return 1.4;
    if (_power < 200) return 1.6;
    return 1.8;
  }

  double get _price => _tb * _kvs * _km * (_kbm[_kbmSelected] ?? 1.0);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ОСАГО-калькулятор')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          DropdownButtonFormField<String>(
            value: _kbmSelected,
            decoration: const InputDecoration(labelText: 'КБМ (бонус-малус)'),
            items: _kbm.keys
                .map((k) => DropdownMenuItem(value: k, child: Text(k)))
                .toList(),
            onChanged: (v) => setState(() => _kbmSelected = v ?? _kbmSelected),
          ),
          const SizedBox(height: 16),
          Text('Возраст водителя: ${_age.round()}'),
          Slider(value: _age, min: 18, max: 80, onChanged: (v) => setState(() => _age = v)),
          Text('Стаж: ${_experience.round()} лет'),
          Slider(value: _experience, min: 0, max: 50, onChanged: (v) => setState(() => _experience = v)),
          Text('Мощность: ${_power.round()} л.с.'),
          Slider(value: _power, min: 50, max: 300, onChanged: (v) => setState(() => _power = v)),
          const SizedBox(height: 16),
          Card(
            color: Colors.green.shade50,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Примерная стоимость ОСАГО:',
                      style: TextStyle(fontSize: 16)),
                  const SizedBox(height: 6),
                  Text('${_price.toStringAsFixed(0)} ₽/год',
                      style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Калькулятор даёт ориентировочную оценку. Точная цена определяется '
            'страховой компанией по актуальным коэффициентам ЦБ РФ.',
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: () => openLink(PartnerLinks.osago),
            icon: const Icon(Icons.open_in_new),
            label: const Text('Оформить ОСАГО по выгодной цене'),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
//  4. МОЙ ГАРАЖ — напоминания (хранение локально)
// ============================================================================
class Car {
  String id, name, plate;
  int power;
  DateTime? dateTo, dateOsago, dateShiny;

  Car({
    required this.id,
    required this.name,
    required this.plate,
    this.power = 100,
    this.dateTo,
    this.dateOsago,
    this.dateShiny,
  });

  Map<String, dynamic> toJson() => {
        'id': id, 'name': name, 'plate': plate, 'power': power,
        'dateTo': dateTo?.toIso8601String(),
        'dateOsago': dateOsago?.toIso8601String(),
        'dateShiny': dateShiny?.toIso8601String(),
      };

  factory Car.fromJson(Map<String, dynamic> j) => Car(
        id: j['id'] ?? '',
        name: j['name'] ?? '',
        plate: j['plate'] ?? '',
        power: j['power'] ?? 100,
        dateTo: j['dateTo'] == null ? null : DateTime.parse(j['dateTo']),
        dateOsago: j['dateOsago'] == null ? null : DateTime.parse(j['dateOsago']),
        dateShiny: j['dateShiny'] == null ? null : DateTime.parse(j['dateShiny']),
      );
}

class GarazhPage extends StatefulWidget {
  const GarazhPage({super.key});
  @override
  State<GarazhPage> createState() => _GarazhPageState();
}

class _GarazhPageState extends State<GarazhPage> {
  List<Car> _cars = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final p = await SharedPreferences.getInstance();
    final s = p.getString('cars');
    if (s != null) {
      setState(() => _cars = (jsonDecode(s) as List)
          .map((e) => Car.fromJson(e as Map<String, dynamic>))
          .toList());
    }
  }

  Future<void> _save() async {
    final p = await SharedPreferences.getInstance();
    await p.setString('cars', jsonEncode(_cars.map((c) => c.toJson()).toList()));
  }

  int? _daysLeft(DateTime? d) =>
      d == null ? null : d.difference(DateTime.now()).inDays;

  Widget _eventRow(String title, DateTime? d) {
    final days = _daysLeft(d);
    Color color;
    String text;
    if (days == null) {
      color = Colors.grey;
      text = 'не задано';
    } else if (days < 7) {
      color = Colors.red;
      text = days < 0 ? 'просрочено ${-days} дн.!' : 'через $days дн.!';
    } else if (days < 30) {
      color = Colors.orange;
      text = 'через $days дн.';
    } else {
      color = Colors.green;
      text = 'через $days дн.';
    }
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Icon(Icons.circle, size: 8, color: color),
          const SizedBox(width: 8),
          Text('$title: ', style: const TextStyle(fontWeight: FontWeight.w500)),
          Text(text, style: TextStyle(color: color, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Future<void> _edit([Car? car]) async {
    final result = await Navigator.push(
        context, MaterialPageRoute(builder: (_) => CarEditPage(car: car)));
    if (result is Car) {
      setState(() {
        final i = _cars.indexWhere((c) => c.id == result.id);
        if (i >= 0) {
          _cars[i] = result;
        } else {
          _cars.add(result);
        }
      });
      await _save();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Мой гараж')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _edit(),
        icon: const Icon(Icons.add),
        label: const Text('Авто'),
      ),
      body: _cars.isEmpty
          ? const Center(
              child: Text('Пока пусто.\nДобавьте первый автомобиль.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.grey)))
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 90),
              itemCount: _cars.length,
              itemBuilder: (context, i) {
                final c = _cars[i];
                return Dismissible(
                  key: Key(c.id),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  onDismissed: (_) {
                    setState(() => _cars.removeAt(i));
                    _save();
                  },
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.directions_car),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text('${c.name}  ·  ${c.plate}',
                                    style: const TextStyle(
                                        fontSize: 17, fontWeight: FontWeight.bold)),
                              ),
                              IconButton(
                                icon: const Icon(Icons.edit_outlined),
                                onPressed: () => _edit(c),
                              ),
                            ],
                          ),
                          const Divider(),
                          _eventRow('ТО', c.dateTo),
                          _eventRow('Страховка', c.dateOsago),
                          _eventRow('Сезонная переобувка', c.dateShiny),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}

class CarEditPage extends StatefulWidget {
  final Car? car;
  const CarEditPage({super.key, this.car});
  @override
  State<CarEditPage> createState() => _CarEditPageState();
}

class _CarEditPageState extends State<CarEditPage> {
  late final TextEditingController _name =
      TextEditingController(text: widget.car?.name ?? '');
  late final TextEditingController _plate =
      TextEditingController(text: widget.car?.plate ?? '');
  late final TextEditingController _power =
      TextEditingController(text: '${widget.car?.power ?? 100}');
  DateTime? _to = widget.car?.dateTo;
  DateTime? _osago = widget.car?.dateOsago;
  DateTime? _shiny = widget.car?.dateShiny;

  Future<void> _pickDate(String title, DateTime? current,
      void Function(DateTime) onPick) async {
    final d = await showDatePicker(
      context: context,
      initialDate: current ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2040),
      helpText: title,
    );
    if (d != null) setState(() => onPick(d));
  }

  String _fmt(DateTime? d) =>
      d == null ? 'не задано' : '${d.day}.${d.month}.${d.year}';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.car == null ? 'Новое авто' : 'Редактирование')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
              controller: _name,
              decoration: const InputDecoration(labelText: 'Марка и модель')),
          const SizedBox(height: 12),
          TextField(
              controller: _plate,
              textCapitalization: TextCapitalization.characters,
              decoration: const InputDecoration(labelText: 'Госномер')),
          const SizedBox(height: 12),
          TextField(
              controller: _power,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Мощность, л.с.')),
          const SizedBox(height: 16),
          ListTile(
            title: Text('Следующее ТО: ${_fmt(_to)}'),
            trailing: const Icon(Icons.calendar_month),
            onTap: () => _pickDate('Дата ТО', _to, (d) => _to = d),
          ),
          ListTile(
            title: Text('Окончание страховки: ${_fmt(_osago)}'),
            trailing: const Icon(Icons.calendar_month),
            onTap: () => _pickDate('Дата страховки', _osago, (d) => _osago = d),
          ),
          ListTile(
            title: Text('Переобувка: ${_fmt(_shiny)}'),
            trailing: const Icon(Icons.calendar_month),
            onTap: () => _pickDate('Дата переобувки', _shiny, (d) => _shiny = d),
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: () {
              if (_name.text.trim().isEmpty || _plate.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Заполните марку и госномер')));
                return;
              }
              final car = Car(
                id: widget.car?.id ??
                    DateTime.now().millisecondsSinceEpoch.toString(),
                name: _name.text.trim(),
                plate: _plate.text.trim().toUpperCase(),
                power: int.tryParse(_power.text.trim()) ?? 100,
                dateTo: _to, dateOsago: _osago, dateShiny: _shiny,
              );
              Navigator.pop(context, car);
            },
            icon: const Icon(Icons.save),
            label: const Text('Сохранить'),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
//  5. ПАРТНЁРСКИЕ ПРЕДЛОЖЕНИЯ
// ============================================================================
class PartnerPage extends StatelessWidget {
  const PartnerPage({super.key});

  @override
  Widget build(BuildContext context) {
    final offers = <_Offer>[
      _Offer('ОСАГО по выгодной цене', 'Сравнение тарифов страховых',
          Icons.verified_user, Colors.green, PartnerLinks.osago),
      _Offer('Кредит на автомобиль', 'Одобрение за 5 минут онлайн',
          Icons.account_balance_wallet, Colors.blue, PartnerLinks.kreditAvto),
      _Offer('Проверка авто перед покупкой', 'История по VIN: ДТП, залог, пробег',
          Icons.fact_check, Colors.orange, PartnerLinks.proverkaVin),
      _Offer('Шины и шиномонтаж', 'Подбор и запись онлайн',
          Icons.tire_repair, Colors.purple, PartnerLinks.shiny),
      _Offer('Оплата штрафов со скидкой', '50% при оплате в первые 20 дней',
          Icons.discount, Colors.red, PartnerLinks.shtrafyOplata),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Партнёрские предложения')),
      body: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: offers.length,
        itemBuilder: (context, i) {
          final o = offers[i];
          return Card(
            margin: const EdgeInsets.only(bottom: 10),
            child: ListTile(
              leading: CircleAvatar(
                  backgroundColor: o.color.withOpacity(0.12),
                  child: Icon(o.icon, color: o.color)),
              title: Text(o.title, style: const TextStyle(fontWeight: FontWeight.w600)),
              subtitle: Text(o.subtitle),
              trailing: const Icon(Icons.open_in_new),
              onTap: () => openLink(o.url),
            ),
          );
        },
      ),
    );
  }
}

class _Offer {
  final String title, subtitle, url;
  final IconData icon;
  final Color color;
  _Offer(this.title, this.subtitle, this.icon, this.color, this.url);
}
