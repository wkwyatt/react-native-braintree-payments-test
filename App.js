/**
 * Sample React Native App
 * https://github.com/facebook/react-native
 * @flow
 */

import React, { Component } from 'react';
import {
  Platform,
  StyleSheet,
  TouchableOpacity,
  Text,
  View,
  NativeModules
} from 'react-native';
import Payments from './nativeModules'


const instructions = Platform.select({
  ios: 'Press Cmd+R to reload,\n' +
    'Cmd+D or shake for dev menu',
  android: 'Double tap R on your keyboard to reload,\n' +
    'Shake or press menu button for dev menu',
});
// use own tokenization key or sandbox key

// let CLIENT_TOKEN = <your sandbox Key>

export default class App extends Component {
  constructor() {
    super();
    this.state = {
      user: null
    };
  }
  componentDidMount() {
      Payments.init(CLIENT_TOKEN)
  }
  onItemPress = () => {
    console.log('onitem press calling');

    Payments.showDropIn().then((nonce) => {
      console.log('nonce', nonce)
      // Do something with nonce
    }).catch((error) => console.warn("ERROR: ", error.message));
  }

  render() {
    return (
      <View style={styles.container}>
        <Text style={{ fontSize: 18, fontWeight: 'bold', marginBottom: 20 }}>Welcome to payment module</Text>
        <TouchableOpacity onPress={() => this.onItemPress()}>
          <Text style={styles.welcome}>
          </Text>
          <Text style={styles.welcome}>
            make payments
        </Text>
        </TouchableOpacity>
      </View>
    );
  }
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    backgroundColor: '#F5FCFF',
  },
  welcome: {
    fontSize: 20,
    textAlign: 'center',
    margin: 10,
  },
  instructions: {
    textAlign: 'center',
    color: '#333333',
    marginBottom: 5,
  },
});
