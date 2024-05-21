import 'package:flutter/foundation.dart';

class PaymentsLogic {
  List<Group> groups;
  User currentUser;

  PaymentsLogic(this.groups, this.currentUser);

  double getTotalDebtForUser(User user) {
    double totalDebt = 0.0;
    for (Group group in groups) {
      totalDebt += getDebtOwedToUser(user, group);
    }
    return totalDebt;
  }

  double getDebtOwedToUser(User user, Group group) {
    double debtOwed = 0.0;
    for (User member in group.members) {
      if (member == user) {
        debtOwed -= member.debts;
      } else {
        debtOwed += member.debts;
      }
    }
    return debtOwed;
  }

  Map<User, double> getIndividualBreakdownForGroup(Group group) {
    Map<User, double> breakdown = {};
    for (User user in group.members) {
      if (user != currentUser) {
        double debt = getDebtOwedToUser(currentUser, group) - getDebtOwedToUser(user, group);
        breakdown[user] = debt;
      } else {
        breakdown[user] = 0.0; // Initialize with 0.0 for the current user
      }
    }
    return breakdown;
  }

  void createDebt(Group group, User creditor, List<User> debtors, double amount,
      String description, PaymentSplitMethod splitMethod, {Map<User, double>? customSplit}) {
    Debt debt = Debt(creditor, debtors, amount, description);

    if (splitMethod == PaymentSplitMethod.even) {
      debt.splitEvenly();
    } else if (splitMethod == PaymentSplitMethod.custom && customSplit != null) {
      debt.splitCustom(customSplit);
    }

    group.addDebt(amount);
  }
}

enum PaymentSplitMethod { even, custom }

class Group {
  String name;
  List<User> members;
  double debts;

  Group(this.name, this.members) : debts = 0.0;

  void addDebt(double amount) {
    debts += amount;
  }
}

class User {
  String name;
  double debts;

  User(this.name) : debts = 0.0;

  void addDebt(double amount) {
    debts += amount;
  }
}

class Debt {
  User creditor;
  List<User> debtors;
  double amount;
  String description;

  Debt(this.creditor, this.debtors, this.amount, this.description);

  void splitEvenly() {
    double splitAmount = amount / debtors.length;
    for (User debtor in debtors) {
      debtor.addDebt(splitAmount);
    }
  }

  void splitCustom(Map<User, double> customSplit) {
    for (User debtor in customSplit.keys) {
      debtor.addDebt(customSplit[debtor] ?? 0.0); // Use 0.0 as default if value is null
    }
  }
}