import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:new_debts_list/storage.dart';
import 'data.dart';
import 'dialogs.dart';

class ProfilesList extends StatefulWidget {
  final ProfilesStorage storage;

  const ProfilesList(this.storage, {Key? key}) : super(key: key);

  @override
  _ProfilesListState createState() => _ProfilesListState();
}

class _ProfilesListState extends State<ProfilesList> {
  List<Profile> _profiles = [];
  bool _loadingProfiles = true;

  @override
  void initState() {
    super.initState();

    widget.storage.isFileExists.then((exists) {
      if (!exists) {
        widget.storage.createFile();
        Navigator.of(context).pushReplacementNamed('/onboarding');
      }
    });

    widget.storage.readProfiles().then((value) {
      setState(() {
        _profiles = value;
        _loadingProfiles = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget body;
    if (_loadingProfiles) {
      body = Center(child: CircularProgressIndicator());
    } else if (_profiles.length == 0) {
      body = Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Icon(
                Icons.receipt,
                color: Theme.of(context).primaryColor,
                size: 64,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Здесь пусто...',
                style: TextStyle(
                  fontSize: 28,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Добавьте людей, нажав на +.',
                style: TextStyle(
                  color: Colors.grey,
                  fontStyle: FontStyle.italic,
                  fontSize: 18,
                ),
              ),
            )
          ],
        ),
      );
    } else {
      body = ListView.builder(
        itemCount: _profiles.length,
        itemBuilder: (context, index) {
          return _ProfileCard(
            _profiles[index],
            () {
              setState(() {
                _profiles.removeAt(index);
              });
              widget.storage.writeProfiles(_profiles);
            },
            () {
              widget.storage.writeProfiles(_profiles);
            },
          );
        },
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Долговая книжка'),
        centerTitle: true,
        actions: [
          PopupMenuButton(
            onSelected: (value) {
              switch (value) {
                case MenuItem.removeAllProfiles:
                  setState(() {
                    _profiles.clear();
                  });
                  widget.storage.writeProfiles(_profiles);
                  break;
                case MenuItem.onboarding:
                  Navigator.of(context).pushReplacementNamed('/onboarding');
                  break;
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: MenuItem.removeAllProfiles,
                child: Text('Удалить все профили'),
              ),
              PopupMenuItem(
                value: MenuItem.onboarding,
                child: Text('Показать гид'),
              ),
            ],
          ),
        ],
      ),
      body: body,
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) {
              return AddProfileDialog((profile) {
                setState(() {
                  _profiles.add(profile);
                });
                widget.storage.writeProfiles(_profiles);
              });
            },
          );
        },
      ),
    );
  }
}

class _ProfileCard extends StatefulWidget {
  final Profile profile;
  final void Function() removeProfile;
  final void Function() saveProfiles;

  const _ProfileCard(this.profile, this.removeProfile, this.saveProfiles,
      {Key? key})
      : super(key: key);

  @override
  _ProfileCardState createState() => _ProfileCardState();
}

class _ProfileCardState extends State<_ProfileCard>
    with TickerProviderStateMixin {
  bool _expanded = false;
  bool _showAreYouSureButton = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: () {
          setState(() {
            _expanded = !_expanded;
            if (_expanded) _showAreYouSureButton = false;
          });
        },
        onLongPress: () {
          showDialog(
              context: context,
              builder: (context) {
                return EditProfileDialog(widget.profile.name, (name) {
                  setState(() {
                    widget.profile.name = name;
                  });
                });
              });
        },
        child: Column(
          children: [
            ListTile(
              title: Text(
                widget.profile.name,
                style: TextStyle(
                  fontSize: 20,
                ),
              ),
              trailing: Text(
                widget.profile.sum.toStringAsFixed(2),
                style: TextStyle(
                  fontSize: 24,
                ),
              ),
            ),
            AnimatedCrossFade(
              duration: Duration(milliseconds: 300),
              sizeCurve: Curves.decelerate,
              firstChild: Container(),
              secondChild: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Divider(),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Center(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ActionButton(
                              context,
                              icon: Icons.delete,
                              label: _showAreYouSureButton
                                  ? 'Вы уверены?'
                                  : 'Удалить',
                              onPressed: () {
                                if (!_showAreYouSureButton) {
                                  setState(() {
                                    _showAreYouSureButton = true;
                                  });
                                } else {
                                  widget.removeProfile.call();
                                }
                              },
                            ),
                            ActionButton(
                              context,
                              icon: Icons.done_all,
                              label: 'Очистить',
                              onPressed: () {
                                setState(() {
                                  widget.profile.debts.clear();
                                });
                                widget.saveProfiles.call();
                              },
                              disabled: widget.profile.debts.isEmpty,
                            ),
                            ActionButton(
                              context,
                              icon: Icons.merge_type,
                              label: 'Объединить',
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (context) {
                                    return MergeDebtsDialog(
                                      widget.profile.debts,
                                      (List<Debt> debts,
                                          String newDescription) {
                                        double sum = 0;
                                        for (Debt d in debts) {
                                          sum += d.amount;
                                        }
                                        setState(() {
                                          for (Debt d in debts) {
                                            widget.profile.remove(d);
                                          }
                                          widget.profile
                                              .add(Debt(newDescription, sum));
                                        });
                                        widget.saveProfiles.call();
                                      },
                                    );
                                  },
                                );
                              },
                              disabled: widget.profile.debts.length < 2,
                            ),
                            ActionButton(
                              context,
                              icon: Icons.add,
                              label: 'Добавить',
                              onPressed: () async {
                                Debt? debtToAdd;
                                await showDialog(
                                  context: context,
                                  builder: (context) {
                                    return AddDebtDialog(
                                      widget.profile,
                                      (Debt debt) => debtToAdd = debt,
                                    );
                                  },
                                );
                                if (debtToAdd != null) {
                                  setState(() {
                                    widget.profile.add(debtToAdd!);
                                  });
                                  widget.saveProfiles.call();
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  widget.profile.debts.isNotEmpty ? Divider() : Container(),
                ]..addAll(widget.profile.debts
                    .map(
                      (e) => ListTile(
                        onTap: () {
                          showDialog(
                              context: context,
                              builder: (context) {
                                return PayPartOfSumDialog(e.amount,
                                    (double part) {
                                  if (part == e.amount) {
                                    setState(() {
                                      widget.profile.remove(e);
                                    });
                                  } else {
                                    setState(() {
                                      widget
                                          .profile
                                          .debts[
                                              widget.profile.debts.indexOf(e)]
                                          .amount -= part;
                                    });
                                  }
                                  widget.saveProfiles.call();
                                });
                              });
                        },
                        onLongPress: () {
                          setState(() {
                            widget.profile.remove(e);
                          });
                          widget.saveProfiles.call();
                        },
                        title: Text(e.description),
                        trailing: Text(
                          '${e.amount.toStringAsFixed(2)}',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    )
                    .toList()),
              ),
              crossFadeState: _expanded
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
            ),
            Divider(
              height: 1,
              thickness: 0.6,
            ),
            Center(
              child: Icon(
                _expanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                color: Colors.grey,
                size: 16,
              ),
            )
          ],
        ),
      ),
    );
  }
}

class ActionButton extends StatelessWidget {
  final BuildContext context;
  final IconData icon;
  final String label;
  final void Function() onPressed;
  final bool? disabled;

  const ActionButton(
    this.context, {
    Key? key,
    required this.icon,
    required this.label,
    required this.onPressed,
    this.disabled,
  }) : super(key: key);

  Color getColor() {
    if (disabled == null || !disabled!)
      return Theme.of(context).buttonColor;
    else
      return Theme.of(context).disabledColor;
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(4),
      onTap: (disabled == null || !disabled!) ? onPressed : null,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Icon(
                icon,
                color: getColor(),
              ),
            ),
            Text(
              label.toUpperCase(),
              style: TextStyle(
                color: getColor(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

enum MenuItem {
  removeAllProfiles,
  onboarding,
}
