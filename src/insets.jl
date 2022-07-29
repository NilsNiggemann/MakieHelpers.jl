function getbboxatPoint(ax,coords,extent = (30,30))
    width,height = extent
    bbox = lift(ax.scene.camera.projectionview, ax.scene.px_area) do _, pxa
        p = Makie.project(ax.scene, Point(coords...))
        
        c = p + pxa.origin
        R = Rect2f(c .- Point2f(width, height),(2*width,2* height))
        R
    end
    return bbox
end

function insetAtPoint(fig,ax,Point,extent = (30,30);zorder = 100,kwargs...)

    bbox = getbboxatPoint(ax,Point,extent)

    ax2 = Axis(fig, bbox = bbox;kwargs...)
    translate!(ax2.blockscene, 0, 0, zorder)
    return ax2
end
