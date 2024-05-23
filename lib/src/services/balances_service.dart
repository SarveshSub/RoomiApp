import 'dart:math';
import 'package:flutter/foundation.dart';

class PaymentsLogic extends ChangeNotifier {
  List<Group> groups;
  User currentUser;

  PaymentsLogic(this.groups, this.currentUser);
  double getTotalBalanceForUser(User user) {
    double totalBalance = 0.0;
    for (Group group in groups) {
      totalBalance += getBalanceForGroup(user, group);
    }
    return totalBalance;
  }

  double getBalanceForGroup(User user, Group group) {
    double balance = 0.0;
    for (Debt debt in group.debts) {
      if (debt.creditor == user) {
        balance += debt.amount;
      } else if (debt.debtor == user) {
        balance -= debt.amount;
      }
    }
    return balance;
  }

  Map<User, double> getIndividualBreakdownForGroup(Group group) {
    Map<User, double> breakdown = {};
    for (User member in group.members) {
      if (member != currentUser) {
        double balance = getBalanceForGroup(member, group);
        breakdown[member] = balance;
      }
    }
    return breakdown;
  }

  void createDebt(Group group, User creditor, List<User> debtors, double amount, String description) {
    double individualAmount = amount / debtors.length;
    for (User debtor in debtors) {
      Debt debt = Debt(creditor, debtor, individualAmount, description);
      group.addDebt(debt);
      optimizePayments(group);
    }
    notifyListeners();
  }

  void optimizePayments(Group group) {
    Map<User, double> balances = {};

    // Calculate balances for each user in the group
    for (User member in group.members) {
      balances[member] = getBalanceForGroup(member, group);
    }

    // Iterate through the balances and optimize debts
    for (User creditor in balances.keys) {
      double creditorBalance = balances[creditor]!;
      if (creditorBalance > 0) {
        for (User debtor in balances.keys) {
          double debtorBalance = balances[debtor]!;
          if (debtorBalance < 0) {
            double transferAmount = min(creditorBalance, -debtorBalance);
            if (transferAmount > 0) {
              // Create a new debt from the debtor to the creditor
              Debt debt = Debt(creditor, debtor, transferAmount, "Optimized Payment");
              group.addDebt(debt);

              // Update the balances
              balances[creditor] = creditorBalance - transferAmount;
              balances[debtor] = debtorBalance + transferAmount;

              // Break the loop if the creditor's balance becomes zero
              if (balances[creditor] == 0) {
                break;
              }
            }
          }
        }
      }
    }
  }
}

class Group {
  String name;
  List<User> members;
  List<Debt> debts;

  Group(this.name, this.members) : debts = [];

  void addDebt(Debt debt) {
    debts.add(debt);
  }
}

class User {
  String name;

  User(this.name);
}

class Debt {
  User creditor;
  User debtor;
  double amount;
  String description;

  Debt(this.creditor, this.debtor, this.amount, this.description);
}