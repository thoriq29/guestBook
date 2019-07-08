class Events {
  var name;
  var category;
  var address;
  var created_at;
  var is_active;
  var owner;
  var start_time;
  var id;

  Events(
      { this.name,
        this.category,
        this.address,
        this.created_at,
        this.is_active,
        this.owner,
        this.start_time,
        this.id
      });

      factory    Events.fromData(Map<String, dynamic> data, id) {
        return Events(
          name : data['name']??"",
          category : data['category'] ?? "",
          address : data['address'] ?? "",
          created_at: data['created_at']??"",
          is_active: data['is_active']??"",
          owner: data['owner'],
          start_time: data['start_time'],
          id: id
        );
      }
      
}