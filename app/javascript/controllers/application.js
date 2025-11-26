import { Application } from "@hotwired/stimulus"
import { Autocomplete } from "stimulus-autocomplete" // コンポーネントの読み込み

const application = Application.start()

application.register("autocomplete", Autocomplete) // Autocompleteコントローラを使用する記述

// Configure Stimulus development experience
application.debug = false
window.Stimulus   = application

export { application }
