import { LightningElement } from 'lwc';

export default class HelloWorld extends LightningElement {
  text = 'World'
  changeHandler(e) {
    this.text = e.target.value
  }
}