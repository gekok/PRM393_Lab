class Vehicle {
  final String brand;
  final int year;

  Vehicle(this.brand, this.year);

  void startEngine(){
    print('Khởi động phương tiện...');
  }
}

class Car extends Vehicle{
  final bool isElectric;

  Car(String brand, int year, this.isElectric)
      : super(brand,year);

  Car.tesla(int year)
      : isElectric= true,
        super('Tesla', year);

  @override
  void startEngine(){
    if(isElectric){
      print('$brand Khởi động bằng động cơ điện');
    }else{
      print('$brand khởi động bằng động cơ xăng');
    }
  }
}

void main(){
  final normalCar= Car('Toyota', 2020, false);
  normalCar.startEngine();

  final teslaCar= Car.tesla(2024);
  teslaCar.startEngine();
}
