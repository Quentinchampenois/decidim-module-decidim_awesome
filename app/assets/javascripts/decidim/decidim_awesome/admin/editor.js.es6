// = require quill.min
// = require image-drop.min
// = require image-resize.min
// = require_self

((exports) => {
  exports.DecidimAwesome = exports.DecidimAwesome || {};

  // Redefines Quill editor with images
  if(exports.DecidimAwesome.allow_images_in_full_editor) {
  	console.log("Awesome config",exports.DecidimAwesome);

	  const quillFormats = ["bold", "italic", "link", "underline", "header", "list", "video", "image"];

	  const createQuillEditor = (container) => {
	    const toolbar = $(container).data("toolbar");
	    const disabled = $(container).data("disabled");

	    let quillToolbar = [
	      ["bold", "italic", "underline"],
	      [{ list: "ordered" }, { list: "bullet" }],
	      ["link", "clean"]
	    ];

	    if (toolbar === "full") {
	      quillToolbar = [
	        [{ header: [1, 2, 3, 4, 5, 6, false] }],
	        ...quillToolbar,
	        ["video", "image"]
	      ];
	    } else if (toolbar === "basic") {
	      quillToolbar = [
	        ...quillToolbar,
	        ["video"]
	      ];
	    }

	    const $input = $(container).siblings('input[type="hidden"]');
	    const quill = new Quill(container, {
	      modules: {
	        toolbar: quillToolbar,
	        imageResize: {
	          modules: ["Resize", "DisplaySize"]
	        },
	        imageDrop: true
	      },
	      formats: quillFormats,
	      theme: "snow"
	    });

	    if (disabled) {
	      quill.disable();
	    }

	    quill.on("text-change", () => {
	      const text = quill.getText();

	      // Triggers CustomEvent with the cursor position
	      // It is required in input_mentions.js
	      let event = new CustomEvent("quill-position", {
	        detail: quill.getSelection()
	      });
	      container.dispatchEvent(event);

	      if (text === "\n") {
	        $input.val("");
	      } else {
	        $input.val(quill.root.innerHTML);
	      }
	    });

	    quill.root.innerHTML = $input.val() || "";
	  };

	  const quillEditor = () => {
	    $(".editor-container").each((idx, container) => {
	      createQuillEditor(container);
	    });
	  };

	  exports.Decidim = exports.Decidim || {};
	  exports.Decidim.quillEditor = quillEditor;
	  exports.Decidim.createQuillEditor = createQuillEditor;

  }
})(window);