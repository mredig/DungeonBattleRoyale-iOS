//
//  Shine.fsh
//  DungeonBattleRoyale
//
//  Created by Michael Redig on 2/18/20.
//  Copyright © 2020 joshua kaunert. All rights reserved.
//

void main() {
	vec4 currentColor = texture2D(u_texture, v_tex_coord);

	if (currentColor.a > 0.0 && (currentColor.r != currentColor.g && currentColor.g != currentColor.b)) {
		currentColor.rgb += u_scale;
		currentColor.rgb = min(currentColor.rgb, 1.0);
	}
	gl_FragColor = currentColor;
}
