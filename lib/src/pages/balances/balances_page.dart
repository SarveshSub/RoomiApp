import 'package:flutter/material.dart';
import '../../services/balances_service.dart';

class BalancesPage extends StatefulWidget {
  const BalancesPage({super.key});

  @override
  _BalancesPageState createState() => _BalancesPageState();
}

class _BalancesPageState extends State<BalancesPage> {
  late PaymentsLogic paymentsLogic;
  User currentUser = User('User 1');

  @override
  void initState() {
    super.initState();
    // Add dummy groups and debts for testing
    List<Group> groups = [
      Group('Group 1', [User('User 1'), User('User 2'), User('User 3')]),
      Group('Group 2', [User('User 1'), User('User 4'), User('User 5')]),
    ];
    paymentsLogic = PaymentsLogic(groups, currentUser);
  }

  @override
  Widget build(BuildContext context) {
    double totalBalance = paymentsLogic.getTotalBalanceForUser(currentUser);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Balances'),
        centerTitle: true,
        elevation: 0,
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: Theme.of(context).primaryColor,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  totalBalance >= 0 ? 'You are owed:' : 'You owe:',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '\$${totalBalance.abs().toStringAsFixed(2)}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: paymentsLogic.groups.length,
              itemBuilder: (context, index) {
                Group group = paymentsLogic.groups[index];
                double balance = paymentsLogic.getBalanceForGroup(currentUser, group);
                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ListTile(
                    title: Text(
                      group.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      balance >= 0
                          ? 'You are owed: \$${balance.toStringAsFixed(2)}'
                          : 'You owe: \$${(-balance).toStringAsFixed(2)}',
                      style: TextStyle(
                        color: balance >= 0 ? Colors.green : Colors.red,
                      ),
                    ),
                    trailing: const Icon(Icons.arrow_forward),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => GroupDetailsPage(
                            group: group,
                            paymentsLogic: paymentsLogic,
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddPaymentPage(
                groups: paymentsLogic.groups,
                paymentsLogic: paymentsLogic,
              ),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class GroupDetailsPage extends StatelessWidget {
  final Group group;
  final PaymentsLogic paymentsLogic;

  const GroupDetailsPage({super.key, required this.group, required this.paymentsLogic});

  @override
  Widget build(BuildContext context) {
    Map<User, double> breakdown = paymentsLogic.getIndividualBreakdownForGroup(group);

    return Scaffold(
      appBar: AppBar(
        title: Text(group.name),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: breakdown.length,
              itemBuilder: (context, index) {
                User user = breakdown.keys.elementAt(index);
                double amount = breakdown[user]!;
                return ListTile(
                  title: Text(user.name),
                  subtitle: Text('Amount: \$${amount.toStringAsFixed(2)}'),
                  onTap: () {
                    // Show dialog to add a description for the payment
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AddPaymentPage(
                        groups: [group],
                        paymentsLogic: paymentsLogic,
                      ),
                    ),
                  );
                },
                child: const Text('Add Payment'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AddPaymentPage extends StatefulWidget {
  final List<Group> groups;
  final PaymentsLogic paymentsLogic;

  const AddPaymentPage({super.key, required this.groups, required this.paymentsLogic});

  @override
  _AddPaymentPageState createState() => _AddPaymentPageState();
}

class _AddPaymentPageState extends State<AddPaymentPage> {
  Group? selectedGroup;
  List<User> selectedDebtors = [];
  double amount = 0.0;
  String description = '';

  @override
  void initState() {
    super.initState();
    selectedGroup = widget.groups.first;
  }

  void _selectDebtors(List<User> debtors) {
    setState(() {
      selectedDebtors = debtors;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Payment'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Group Selection
              DropdownButtonFormField<Group>(
                value: selectedGroup,
                onChanged: (Group? newValue) {
                  setState(() {
                    selectedGroup = newValue;
                    selectedDebtors.clear();
                  });
                },
                items: widget.groups.map((Group group) {
                  return DropdownMenuItem<Group>(
                    value: group,
                    child: Text(group.name),
                  );
                }).toList(),
                decoration: const InputDecoration(
                  labelText: 'Select Group',
                ),
              ),
              const SizedBox(height: 16),
              // Debtor Selection
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DebtorSelectionPage(
                        group: selectedGroup!,
                        onDebtorsSelected: _selectDebtors,
                      ),
                    ),
                  );
                },
                child: const Text('Select Debtors'),
              ),
              const SizedBox(height: 8),
              Text('Selected Debtors: ${selectedDebtors.map((e) => e.name).join(", ")}'),
              const SizedBox(height: 16),
              // Amount Input
              TextFormField(
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  setState(() {
                    amount = double.tryParse(value) ?? 0.0;
                  });
                },
                decoration: const InputDecoration(
                  labelText: 'Amount',
                ),
              ),
              const SizedBox(height: 16),
              // Description Input
              TextFormField(
                onChanged: (value) {
                  setState(() {
                    description = value;
                  });
                },
                decoration: const InputDecoration(
                  labelText: 'Description',
                ),
              ),
              const SizedBox(height: 16),
              // Add Payment Button
              ElevatedButton(
                onPressed: () {
                  if (selectedGroup != null &&
                      selectedDebtors.isNotEmpty &&
                      amount > 0) {
                    widget.paymentsLogic.createDebt(
                      selectedGroup!,
                      widget.paymentsLogic.currentUser,
                      selectedDebtors,
                      amount,
                      description,
                    );
                    Navigator.pop(context);
                  }
                },
                child: const Text('Add Payment'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class DebtorSelectionPage extends StatefulWidget {
  final Group group;
  final Function(List<User>) onDebtorsSelected;

  const DebtorSelectionPage({
    super.key,
    required this.group,
    required this.onDebtorsSelected,
  });

  @override
  _DebtorSelectionPageState createState() => _DebtorSelectionPageState();
}

class _DebtorSelectionPageState extends State<DebtorSelectionPage> {
  List<User> selectedDebtors = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Debtors'),
      ),
      body: ListView.builder(
        itemCount: widget.group.members.length,
        itemBuilder: (context, index) {
          User member = widget.group.members[index];
          return CheckboxListTile(
            title: Text(member.name),
            value: selectedDebtors.contains(member),
            onChanged: (bool? value) {
              setState(() {
                if (value != null && value) {
                  selectedDebtors.add(member);
                } else {
                  selectedDebtors.remove(member);
                }
              });
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          widget.onDebtorsSelected(selectedDebtors);
          Navigator.pop(context);
        },
        child: const Icon(Icons.check),
      ),
    );
  }
}