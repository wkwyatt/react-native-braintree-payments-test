package com.payments.payments;

/**
 * Created by bolisettis on 11/7/17.
 */


import com.facebook.react.bridge.Promise;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.Callback;
import com.facebook.react.bridge.ReadableMap;
import com.facebook.react.bridge.NativeModule;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContext;
import com.facebook.react.bridge.ReactMethod;

import com.facebook.react.bridge.BaseActivityEventListener;

import java.util.Map;

import android.app.Activity;
import android.content.IntentFilter;
import android.hardware.Camera;
import android.view.Window;
import android.graphics.Color;



import android.content.Context;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.net.Uri;
import android.util.Log;
import android.util.SparseArray;
import android.widget.Toast;


import com.facebook.react.uimanager.IllegalViewOperationException;

import java.io.File;
import java.io.FileNotFoundException;

import javax.xml.datatype.XMLGregorianCalendar;

import static android.content.ContentValues.TAG;


import com.braintreepayments.api.dropin.DropInActivity;
import com.braintreepayments.api.dropin.DropInRequest;
import com.braintreepayments.api.dropin.DropInResult;




public class PaymentsModules extends ReactContextBaseJavaModule{

    private final ReactApplicationContext reactContext;
    private Callback successCallback;
    private Callback cancelCallback;

    private Promise braintreePromise;

    private static final int REQUEST_CODE = 1;
    private static final String CANCELED = "CANCELED";
    private static final String ERROR = "ERROR";
    private String token;
    public PaymentsModules(ReactApplicationContext reactContext) {
        super(reactContext);
        this.reactContext = reactContext;
        reactContext.addActivityEventListener(new BraintreeActivityListener());
    }

    @Override
    public String getName() {
        return "Payments";
    }

    public String getToken() {
      return token;
    }

    public void setToken(String token) {
      this.token = token;
    }

    @ReactMethod
    public void init(String token) {
      this.setToken(token);
    }

    @ReactMethod
  public void showDropIn(final Promise promise) {
    this.braintreePromise = promise;

    if(this.getToken() == null) {
      promise.reject(ERROR, "You must call init method first!");
    } else {
      DropInRequest dropInRequest = new DropInRequest().clientToken(this.getToken());

      getCurrentActivity().startActivityForResult(dropInRequest.getIntent(getCurrentActivity()), REQUEST_CODE);
    }
  }

  private class BraintreeActivityListener extends BaseActivityEventListener {
    @Override
    public void onActivityResult(Activity activity, int requestCode, int resultCode, Intent data) {
      if (requestCode == REQUEST_CODE) {
        if (resultCode == Activity.RESULT_OK) {
          DropInResult result = data.getParcelableExtra(DropInResult.EXTRA_DROP_IN_RESULT);

          braintreePromise.resolve(result.getPaymentMethodNonce().getNonce());

          // use the result to update your UI and send the payment method nonce to your server
        } else if (resultCode == Activity.RESULT_CANCELED) {
          // the user canceled

          braintreePromise.reject(CANCELED, "Drop In was canceled.");
        } else {
          // handle errors here, an exception may be available in
          Exception error = (Exception) data.getSerializableExtra(DropInActivity.EXTRA_ERROR);
          braintreePromise.reject(ERROR, error.getMessage());
        }
      }
    }
  }

  @ReactMethod
  public void concatStr(
          Promise promise) {
      promise.resolve("hi" + " " + "hey");
  }


}
