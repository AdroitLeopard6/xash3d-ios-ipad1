#include <OpenGLES/ES1/gl.h>

/*
 * Desktop OpenGL compatibility for OpenGL ES 1.x.
 * glMultiTexCoord2f(s,t) is equivalent to
 * glMultiTexCoord4f(s,t,0,1).
 */
void glMultiTexCoord2f(GLenum target, GLfloat s, GLfloat t)
{
    glMultiTexCoord4f(target, s, t, 0.0f, 1.0f);
}
