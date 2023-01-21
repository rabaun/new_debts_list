class Profile {
  String name;
  List<Debt> debts;

  Profile(this.name, [List<Debt>? debts])
      : this.debts = (debts == null) ? [] : debts;

  factory Profile.fromJson(Map<String, dynamic> json) {
    final List<Debt> list = json['debts'].map<Debt>((e) => Debt.fromJson(e)).toList();
    return Profile(json['name'], list);
  }

  void add(Debt debt) => debts.add(debt);

  bool remove(Debt debt) => debts.remove(debt);

  double get sum =>
      debts.isEmpty ? 0 : debts.map((e) => e.amount).reduce((v, e) => v + e);

  Map<String, dynamic> toJson() => {
        'name': name,
        'debts': debts.map((e) => e.toJson()).toList(),
      };

  @override
  String toString() {
    return 'Profile{name: $name, debts: $debts}';
  }
}

class Debt {
  String description;
  double amount;

  Debt(this.description, this.amount);

  Debt.fromJson(Map<String, dynamic> json)
      : description = json['description'],
        amount = json['amount'];

  Map<String, dynamic> toJson() => {
        'description': description,
        'amount': amount,
      };

  @override
  String toString() {
    return 'Debt{description: $description, amount: $amount}';
  }
}
