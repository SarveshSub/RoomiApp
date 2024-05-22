class PaymentsLogic {
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
      } else if (debt.debtors.contains(user)) {
        balance -= debt.amount / debt.debtors.length;
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
    Debt debt = Debt(creditor, debtors, amount, description);
    group.addDebt(debt);
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
  List<User> debtors;
  double amount;
  String description;

  Debt(this.creditor, this.debtors, this.amount, this.description);
}