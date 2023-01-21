import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'data.dart';

class AddDebtDialog extends StatefulWidget {
  final Profile profile;
  final void Function(Debt debt) addDebt;

  const AddDebtDialog(this.profile, this.addDebt, {Key? key}) : super(key: key);

  @override
  _AddDebtDialogState createState() => _AddDebtDialogState();
}

class _AddDebtDialogState extends State<AddDebtDialog> {
  _DebtType? _selected = _DebtType.theyOwe;
  bool _amountValidationError = false;

  late final TextEditingController descController;
  late final TextEditingController amountController;

  /// Returns true if there is no validation error
  bool checkAndAddDebt() {
    if (_amountValidationError || amountController.text.isEmpty) return false;

    widget.addDebt.call(
      Debt(
        descController.text,
        double.parse(amountController.text) *
            (_selected == _DebtType.iOwe ? -1.0 : 1.0),
      ),
    );
    return true;
  }

  @override
  void initState() {
    super.initState();
    descController = TextEditingController();
    amountController = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    TextField descTextField = TextField(
      autofocus: true,
      controller: descController,
      decoration: InputDecoration(
        border: OutlineInputBorder(),
        labelText: 'Описание',
      ),
    );

    RegExp regexp = RegExp(r'^([0-9]+|\.[0-9]{1,2}|[0-9]+\.[0-9]{0,2})$');
    TextField amountTextField = TextField(
      controller: amountController,
      decoration: InputDecoration(
        border: OutlineInputBorder(),
        labelText: 'Сумма',
        errorText: _amountValidationError ? 'Сумма набрана неверно' : null,
      ),
      keyboardType: TextInputType.numberWithOptions(decimal: true),
      onChanged: (text) {
        if (!regexp.hasMatch(text) && text.isNotEmpty) {
          if (!_amountValidationError) {
            setState(() {
              _amountValidationError = true;
            });
          }
        } else {
          if (_amountValidationError) {
            setState(() {
              _amountValidationError = false;
            });
          }
        }
      },
      onSubmitted: (text) {
        bool success = checkAndAddDebt();
        if (success) Navigator.pop(context);
      },
    );

    return AlertDialog(
      title: Text('Добавить'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            descTextField,
            RadioListTile<_DebtType>(
              title: const Text('Мне должны'),
              value: _DebtType.theyOwe,
              groupValue: _selected,
              onChanged: (_DebtType? value) {
                setState(() {
                  _selected = value;
                });
              },
            ),
            RadioListTile<_DebtType>(
              title: const Text('Я должен'),
              value: _DebtType.iOwe,
              groupValue: _selected,
              onChanged: (_DebtType? value) {
                setState(() {
                  _selected = value;
                });
              },
            ),
            amountTextField,
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text('ОТМЕНА'),
        ),
        TextButton(
          onPressed: () {
            bool success = checkAndAddDebt();
            if (success) Navigator.pop(context);
          },
          child: Text('ДОБАВИТЬ'),
        ),
      ],
    );
  }
}

enum _DebtType { theyOwe, iOwe }

class PayPartOfSumDialog extends StatefulWidget {
  final double debtSum;
  final void Function(double part) payPartOfSum;

  const PayPartOfSumDialog(this.debtSum, this.payPartOfSum, {Key? key})
      : super(key: key);

  @override
  _PayPartOfSumDialogState createState() => _PayPartOfSumDialogState();
}

class _PayPartOfSumDialogState extends State<PayPartOfSumDialog> {
  bool _amountValidationError = false;
  bool _amountExceedsSum = false;

  late final TextEditingController amountController;

  bool checkAndPay() {
    if (_amountValidationError ||
        _amountExceedsSum ||
        amountController.text.isEmpty) return false;

    widget.payPartOfSum.call(
        double.parse(amountController.text) * (widget.debtSum < 0 ? -1 : 1));
    return true;
  }

  @override
  void initState() {
    super.initState();
    amountController = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    RegExp regexp = RegExp(r'^([0-9]+|\.[0-9]{1,2}|[0-9]+\.[0-9]{0,2})$');
    final amountField = TextField(
      controller: amountController,
      decoration: InputDecoration(
        border: OutlineInputBorder(),
        labelText: 'Сумма',
        errorText: _amountValidationError
            ? 'Сумма набрана неверно'
            : (_amountExceedsSum ? 'Заданная часть превышает сумму' : null),
      ),
      keyboardType: TextInputType.numberWithOptions(decimal: true),
      onChanged: (text) {
        if (!regexp.hasMatch(text) && text.isNotEmpty) {
          if (!_amountValidationError) {
            setState(() {
              _amountValidationError = true;
            });
          }
        } else {
          if (_amountValidationError) {
            setState(() {
              _amountValidationError = false;
            });
          }
          if (text.isNotEmpty && double.parse(text) > widget.debtSum.abs()) {
            if (!_amountExceedsSum) {
              setState(() {
                _amountExceedsSum = true;
              });
            }
          } else {
            if (_amountExceedsSum) {
              setState(() {
                _amountExceedsSum = false;
              });
            }
          }
        }
      },
      onSubmitted: (text) {
        bool success = checkAndPay();
        if (success) Navigator.pop(context);
      },
    );

    return AlertDialog(
      title: Text('Оплатить часть'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            amountField,
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Icon(
                      Icons.info_outline,
                      color: Colors.grey,
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        'Вы можете отметить оплаченной сразу всю сумму, удерживая строчку в списке.',
                        style: TextStyle(
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text('ОТМЕНА'),
        ),
        TextButton(
          onPressed: () {
            bool success = checkAndPay();
            if (success) Navigator.pop(context);
          },
          child: Text('ОПЛАТИТЬ'),
        ),
      ],
    );
  }
}

class AddProfileDialog extends StatelessWidget {
  final void Function(Profile profile) addProfile;

  const AddProfileDialog(this.addProfile, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    TextEditingController controller = TextEditingController();
    TextField textField = TextField(
      autofocus: true,
      controller: controller,
      decoration: InputDecoration(
        border: OutlineInputBorder(),
        labelText: 'Имя',
      ),
      onSubmitted: (text) {
        addProfile.call(Profile(text));
        Navigator.pop(context);
      },
    );

    return AlertDialog(
      title: Text("Добавить"),
      content: textField,
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text('ОТМЕНА'),
        ),
        TextButton(
          onPressed: () {
            addProfile.call(Profile(controller.text));
            Navigator.pop(context);
          },
          child: Text('ДОБАВИТЬ'),
        ),
      ],
    );
  }
}

class EditProfileDialog extends StatelessWidget {
  final String oldName;
  final void Function(String name) setProfileName;

  const EditProfileDialog(this.oldName, this.setProfileName, {Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    TextEditingController controller = TextEditingController();
    controller.text = oldName;
    TextField textField = TextField(
      autofocus: true,
      controller: controller,
      decoration: InputDecoration(
        border: OutlineInputBorder(),
        labelText: 'Имя',
      ),
      onSubmitted: (text) {
        setProfileName.call(text);
        Navigator.pop(context);
      },
    );

    return AlertDialog(
      title: Text("Изменить"),
      content: textField,
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text('ОТМЕНА'),
        ),
        TextButton(
          onPressed: () {
            setProfileName.call(controller.text);
            Navigator.pop(context);
          },
          child: Text('ИЗМЕНИТЬ'),
        ),
      ],
    );
  }
}

class MergeDebtsDialog extends StatefulWidget {
  final List<Debt> debts;
  final void Function(List<Debt> debts, String newDescription) mergeDebts;

  const MergeDebtsDialog(this.debts, this.mergeDebts, {Key? key}) : super(key: key);

  @override
  _MergeDebtsDialogState createState() => _MergeDebtsDialogState();
}

class _MergeDebtsDialogState extends State<MergeDebtsDialog> {
  List<Debt> debtsToMerge = [];
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Объединить'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 200,
              width: 300,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(5),
              ),
              child: ListView.builder(
                itemCount: widget.debts.length,
                itemBuilder: (context, index) {
                  return DebtWithCheckboxListTile(
                    debt: widget.debts[index],
                    value: debtsToMerge.contains(widget.debts[index]),
                    onChanged: (bool newValue) {
                      if (newValue) {
                        setState(() {
                          debtsToMerge.add(widget.debts[index]);
                        });
                      } else {
                        setState(() {
                          debtsToMerge.remove(widget.debts[index]);
                        });
                      }
                    },
                  );
                },
              ),
            ),
            SizedBox(height: 8),
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Новое описание',
              ),
              onSubmitted: (text) {
                widget.mergeDebts.call(debtsToMerge, text);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text('ОТМЕНА'),
        ),
        TextButton(
          onPressed: () {
            widget.mergeDebts.call(debtsToMerge, _controller.text);
            Navigator.pop(context);
          },
          child: Text('ОБЪЕДИНИТЬ'),
        ),
      ],
    );
  }
}

class DebtWithCheckboxListTile extends StatelessWidget {
  final Debt debt;
  final bool value;
  final ValueChanged<bool> onChanged;

  const DebtWithCheckboxListTile({
    Key? key,
    required this.debt,
    required this.value,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        onChanged(!value);
      },
      child: Padding(
        padding: const EdgeInsets.only(right: 8.0),
        child: Row(
          children: [
            Checkbox(
              value: value,
              onChanged: (bool? newValue) {
                onChanged(newValue!);
              },
            ),
            Expanded(child: Text(debt.description)),
            Text(debt.amount.toStringAsFixed(2)),
          ],
        ),
      ),
    );
  }
}
