---
title: Web Workers in CoffeeScript
---

If you're looking to implement [Web Workers](https://developer.mozilla.org/en-US/docs/Web/API/Web_Workers_API/Using_web_workers) with a Worker written in [CoffeeScript](https://coffeescript.org/), you may run into the snag that CoffeeScript will compile your worker with a wrapper/closure that looks like `(function() {}).call(this);`, which prevents your Worker's `onmessage` function from properly registering. Have no fear, you don't need to pass `--bare` to your CoffeeScript compiler to fix this! If you just add the line `self.addEventListener('message', onmessage, false)`, your `onmessage` function will be registered and correctly handle `postMessage()` invocations from the parent. Here's a small example with the compiled JS output:

`worker.coffee`:

      console.log('worker loaded')

      onmessage = (e) ->
        console.log('worker received message')
        console.log(e.data)

      self.addEventListener('message', onmessage, false)

Compiled output `worker.js`:

      (function() {
        var onmessage;

        console.log('worker loaded');

        onmessage = function(e) {
          console.log('worker received message');
          return console.log(e.data);
        };

        self.addEventListener('message', onmessage, false);

      }).call(this);
