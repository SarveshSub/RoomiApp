import 'package:flutter/material.dart';
import '../../services/payments_service.dart';

class PaymentsPage extends StatefulWidget {
  const PaymentsPage({Key? key}) : super(key: key);

  @override
  _PaymentsPageState createState() => _PaymentsPageState();
}

class _PaymentsPageState extends State<PaymentsPage> {
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
    double totalDebt = paymentsLogic.getTotalDebtForUser(currentUser);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Payments'),
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
                const Text(
                  'Total Debt',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '\$${totalDebt.toStringAsFixed(2)}',
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
                double debtOwed = paymentsLogic.getDebtOwedToUser(currentUser, group);
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
                      debtOwed <= 0
                          ? 'You are owed: \$${(-debtOwed).toStringAsFixed(2)}'
                          : 'You owe: \$${debtOwed.toStringAsFixed(2)}',
                      style: TextStyle(
                        color: debtOwed <= 0 ? Colors.green : Colors.red,
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

  const GroupDetailsPage({Key? key, required this.group, required this.paymentsLogic})
      : super(key: key);

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

  const AddPaymentPage({Key? key, required this.groups, required this.paymentsLogic})
      : super(key: key);

  @override
  _AddPaymentPageState createState() => _AddPaymentPageState();
}

class _AddPaymentPageState extends State<AddPaymentPage> {
  Group? selectedGroup;
  List<User> selectedDebtors = [];
  User? selectedCreditor;
  double amount = 0.0;
  String description = '';
  PaymentSplitMethod splitMethod = PaymentSplitMethod.even;
  Map<User, double> customSplit = {};

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

  void _selectCreditor(User creditor) {
    setState(() {
      selectedCreditor = creditor;
    });
  }

  void _setSplitMethod(PaymentSplitMethod method) {
    setState(() {
      splitMethod = method;
    });
  }

  void _setCustomSplit(Map<User, double> split) {
    setState(() {
      customSplit = split;
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
                    selectedCreditor = null;
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
              // Creditor Selection
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CreditorSelectionPage(
                        group: selectedGroup!,
                        onCreditorSelected: _selectCreditor,
                      ),
                    ),
                  );
                },
                child: const Text('Select Creditor'),
              ),
              const SizedBox(height: 8),
              Text('Selected Creditor: ${selectedCreditor?.name ?? ""}'),
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
              // Split Method Selection
              ListTile(
                title: const Text('Split Evenly'),
                leading: Radio<PaymentSplitMethod>(
                  value: PaymentSplitMethod.even,
                  groupValue: splitMethod,
                  onChanged: (PaymentSplitMethod? value) {
                    _setSplitMethod(value!);
                  },
                ),
              ),
              ListTile(
                title: const Text('Custom Split'),
                leading: Radio<PaymentSplitMethod>(
                  value: PaymentSplitMethod.custom,
                  groupValue: splitMethod,
                  onChanged: (PaymentSplitMethod? value) {
                    _setSplitMethod(value!);
                  },
                ),
              ),
              const SizedBox(height: 16),
              // Custom Split
              if (splitMethod == PaymentSplitMethod.custom)
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CustomSplitPage(
                          debtors: selectedDebtors,
                          totalAmount: amount,
                          onCustomSplitSet: _setCustomSplit,
                        ),
                      ),
                    );
                  },
                  child: const Text('Set Custom Split'),
                ),
              const SizedBox(height: 16),
              // Add Payment Button
              ElevatedButton(
                onPressed: () {
                  if (selectedGroup != null &&
                      selectedDebtors.isNotEmpty &&
                      selectedCreditor != null &&
                      amount > 0) {
                    widget.paymentsLogic.createDebt(
                      selectedGroup!,
                      selectedCreditor!,
                      selectedDebtors,
                      amount,
                      description,
                      splitMethod,
                      customSplit: customSplit,
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
    Key? key,
    required this.group,
    required this.onDebtorsSelected,
  }) : super(key: key);

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

class CreditorSelectionPage extends StatefulWidget {
  final Group group;
  final Function(User) onCreditorSelected;

  const CreditorSelectionPage({
    Key? key,
    required this.group,
    required this.onCreditorSelected,
  }) : super(key: key);

  @override
  _CreditorSelectionPageState createState() => _CreditorSelectionPageState();
}

class _CreditorSelectionPageState extends State<CreditorSelectionPage> {
  User? selectedCreditor;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Creditor'),
      ),
      body: ListView.builder(
        itemCount: widget.group.members.length,
        itemBuilder: (context, index) {
          User member = widget.group.members[index];
          return RadioListTile<User>(
            title: Text(member.name),
            value: member,
            groupValue: selectedCreditor,
            onChanged: (User? value) {
              setState(() {
                selectedCreditor = value;
              });
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (selectedCreditor != null) {
            widget.onCreditorSelected(selectedCreditor!);
            Navigator.pop(context);
          }
        },
        child: const Icon(Icons.check),
      ),
    );
  }
}
class CustomSplitPage extends StatefulWidget {
  final List<User> debtors;
  final double totalAmount;
  final Function(Map<User, double>) onCustomSplitSet;

  const CustomSplitPage({
    Key? key,
    required this.debtors,
    required this.totalAmount,
    required this.onCustomSplitSet,
  }) : super(key: key);

  @override
  _CustomSplitPageState createState() => _CustomSplitPageState();
}

class _CustomSplitPageState extends State<CustomSplitPage> {
  Map<User, double> customSplit = {};

  @override
  void initState() {
    super.initState();
    for (User debtor in widget.debtors) {
      customSplit[debtor] = 0.0;
    }
  }

  void _setCustomAmount(User debtor, String value) {
    setState(() {
      customSplit[debtor] = double.tryParse(value) ?? 0.0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Custom Split'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: widget.debtors.length,
              itemBuilder: (context, index) {
                User debtor = widget.debtors[index];
                return ListTile(
                  title: Text(debtor.name),
                  subtitle: TextFormField(
                    keyboardType: TextInputType.number,
                    initialValue: customSplit[debtor]!.toStringAsFixed(2),
                    onChanged: (value) => _setCustomAmount(debtor, value),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Total: \$${customSplit.values.fold(0.0, (a, b) => a + b).toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 18.0),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (customSplit.values.fold(0.0, (a, b) => a + b) == widget.totalAmount) {
            widget.onCustomSplitSet(customSplit);
            Navigator.pop(context);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Custom split amounts must add up to the total amount.'),
              ),
            );
          }
        },
        child: const Icon(Icons.check),
      ),
    );
  }
}