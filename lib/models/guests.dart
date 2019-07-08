class Guests {
  var name;
  var  phone;
  var  email;
  var  address;
  var  note;
  var  time;

  Guests(
      {this.name,
      this.phone,
      this.email,
      this.address,
      this.note,
      this.time,});

      factory    Guests.fromData(Map<String, dynamic> data) {
        return Guests(
          name : data['full_name']??"",
          phone : data['phone']??"",
          email : data['email'] ?? "",
          address : data['address'] ?? "",
          note : data['notes'],
          time : data['created_at'] ?? ""
        );
      }
      
}