using Clutter;
using Gdk;

class YamfeImage : Clutter.Image {

	private string _filename = null;

	public string filename {
		get { return _filename; }
		set { set_from_file(value); }
	}

	public YamfeImage.from_file(string path) {
		set_from_file(path);
	}

	private bool set_from_file (string path) {
		if(path != _filename) {
			try	{
				Pixbuf pix = new Pixbuf.from_file(path);
		    	message("bps: %d", pix.bits_per_sample);
		    	message("colorspace: %d", pix.colorspace);
		    	message("alpha: %d", pix.has_alpha?1:0);
		    	message("channels: %d", pix.n_channels);
				this.set_data(	pix.get_pixels(),
		    			    	pix.has_alpha ? Cogl.PixelFormat.RGBA_8888 : Cogl.PixelFormat.RGB_888,
		    					pix.width,
		    					pix.height,
		    					pix.rowstride);

		    	_filename = path;
		    } catch (Error err) {
				stdout.printf("Error: %s\n", err.message);
				return false;
			}
		}
		return true;
	}
}
