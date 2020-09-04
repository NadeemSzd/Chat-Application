
class Model
{
  List<Message> messageList = [
    Message(messages: 'How are you ?',sender: 'Danish',receiver: 'Nadeem'),
    Message(messages: 'Fine and you ?',sender: 'Nadeem',receiver: 'Danish'),
    Message(messages: 'Fine ... ',sender: 'Danish',receiver: 'Nadeem'),
    Message(messages: 'Where ?',sender: 'Nadeem',receiver: 'Danish'),
    Message(messages: 'Lahore',sender: 'Danish',receiver: 'Nadeem'),
    Message(messages: 'and you ?',sender: 'Danish',receiver: 'Nadeem'),
    Message(messages: 'Kasur',sender: 'Nadeem',receiver: 'Danish'),
    Message(messages: 'Ok bro',sender: 'Danish',receiver: 'Nadeem'),
    Message(messages: 'Ook',sender: 'Nadeem',receiver: 'Danish'),
  ];
}


class Message
{
  String messages;
  String sender;
  String receiver;

  Message({this.messages,this.sender,this.receiver});
}