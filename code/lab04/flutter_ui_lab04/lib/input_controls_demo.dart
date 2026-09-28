import 'package:flutter/material.dart';

//màn hình bài 2: Slider, Switch, Radio, DatePicker
// Dùng StatefulWidget vì có 4 giá trị đổi theo tay người dùng
class InputControlsDemo extends StatefulWidget{
  const InputControlsDemo({super.key});

  @override
  State<InputControlsDemo> createState()=> _InputControlsDemoState();
}

class _InputControlsDemoState extends State<InputControlsDemo>{
  //múc âm lượng của Slider, từ 0 tới 100
  double _volume=30;
  //trnajg thái bật tắt Switch
  bool _notificationsOn= true;
  //lựa chọn hiện tại cảu nhóm Radio
  String _genre='Hành động';
  //Ngày đã chọn, null là chưa chọn
  DateTime? _pickedDate;

  // mở hộp chọn ngày của hệ thống rồi chờ
  Future<void> _pickDate() async{
    final now = DateTime.now();
    final result= await showDatePicker(
        context: context,
        initialDate: now,
        firstDate: DateTime(2000),
        lastDate: DateTime(2100),
    );
    // người dùng bấm hủy thì result là null không làm gì thêm
    if(result==null)return;
    //có ngàu mới thì báo Flutter vẽ lại màn hình
    setState(() {
      _pickedDate=result;
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Lab04 ex2 input controls')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          //hiển thị giá trị Slider hiện tại
          Text('Âm Lượng: ${_volume.round()}'),
          Slider(
              value: _volume,
              min: 0,
              max: 100,
              divisions: 10,
              label: '${_volume.round()}',
              onChanged: (newValue){
                setState(() {
                  _volume=newValue;
                });
              },
          ),
          const SizedBox(height: 12,),

          //công tắc bật tắt thông báo
          SwitchListTile(
              title: const Text('Nhận thông báo phim mới'),
              value: _notificationsOn,
              onChanged: (newValue){
                setState(() {
                  _notificationsOn=newValue;
                });
              },
          ),
          const SizedBox(height: 12,),

          //nhóm chọn thể loại, chỉ chọn được 1
          const Text('Thể loại yêu thích: '),
          RadioGroup<String>(
            groupValue: _genre,
            onChanged: (value) {
              setState(() {
                _genre = value!;
              });
            },
            child: Column(
              children: const [
                RadioListTile<String>(
                  title: Text('Hành động'),
                  value: 'Hành động',
                ),
                RadioListTile<String>(
                  title: Text('Hài'),
                  value: 'Hài',
                ),
              ],
            ),
          ),
          const SizedBox(height: 12,),

          //nút mở DatePicker
          ElevatedButton(
              onPressed: _pickDate,
              child: const Text('Chọn ngày xem phim'),
          ),
          const SizedBox(height: 12,),
          //hiển thị ngày đã chọn, chưa chọn hiện '-'
          Text(
            _pickedDate==null
                ? 'Chưa chọn ngày'
                : 'Ngày đã chọn: ${_pickedDate!.day}/${_pickedDate!.month}/${_pickedDate!.year}',
          ),
        ],
      ),
    );
  }
}