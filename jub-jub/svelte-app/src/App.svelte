<script>
  import normal from "./assets/normal-cropped.png";
  import jubjub from "./assets/jub-jub-cropped.png";
  import { fnvHash } from "./lib/fnv-hash";

  let output = "Hello";
  let bla = "";

  $: output = fnvHash(bla).toString(16);
  $: outImg = output == "0" ? jubjub : normal;
</script>

<main>
  <input type="text" bind:value={bla} />
  {output}
  <br />

  <img src={outImg} alt="screenshot" />
</main>

<style>
  /*  */
</style>
