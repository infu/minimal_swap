import old_ledger "canister:ledger";
import new_ledger "canister:ledger";
import Principal "mo:base/Principal";
import Array "mo:base/Array";
import Nat8 "mo:base/Nat8";

actor class Swap() = this {

  public shared ({ caller }) func convert() : async () {
    let amount = await old_ledger.icrc1_balance_of({
      owner = Principal.fromActor(this);
      subaccount = ?callerSubaccount(caller);
    });
    assert switch (await old_ledger.icrc1_transfer({ to = { owner = Principal.fromActor(this); subaccount = null }; subaccount = callerSubaccount(caller); from_subaccount = null; amount; memo = null; created_at_time = null; fee = null })) {
      case (#Ok(_)) true;
      case (#Err(_)) false;
    };
    ignore await new_ledger.icrc1_transfer({
      to = { owner = Principal.fromActor(this); subaccount = null };
      from_subaccount = null;
      amount;
      memo = null;
      created_at_time = null;
      fee = null;
    });
  };

  public shared ({ caller }) func refund() : async () {
    let amount = await old_ledger.icrc1_balance_of({
      owner = Principal.fromActor(this);
      subaccount = ?callerSubaccount(caller);
    });
    ignore await old_ledger.icrc1_transfer({
      to = { owner = caller; subaccount = null };
      subaccount = ?callerSubaccount(caller);
      from_subaccount = null;
      amount;
      memo = null;
      created_at_time = null;
      fee = null;
    });
  };

  private func callerSubaccount(p : Principal) : [Nat8] {
    let a = Array.init<Nat8>(32, 0);
        let pa = Principal.toBlob(p);
        a[0] := Nat8.fromNat(pa.size());

        var pos = 1;
        for (x in pa.vals()) {
                a[pos] := x;
                pos := pos + 1;
            };

        Array.freeze(a);
  };



};
